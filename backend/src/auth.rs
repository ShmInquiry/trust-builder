use actix_web::{web, HttpRequest, HttpResponse};
use sqlx::PgPool;
use uuid::Uuid;

use crate::models::*;

fn generate_token() -> String {
    use rand::Rng;
    let mut rng = rand::thread_rng();
    (0..64)
        .map(|_| {
            let idx = rng.gen_range(0..36);
            if idx < 10 {
                (b'0' + idx) as char
            } else {
                (b'a' + idx - 10) as char
            }
        })
        .collect()
}

pub async fn get_user_from_token(pool: &PgPool, req: &HttpRequest) -> Option<Uuid> {
    let token = req
        .headers()
        .get("Authorization")?
        .to_str()
        .ok()?
        .strip_prefix("Bearer ")?
        .to_string();

    let row: Option<(Uuid,)> =
        sqlx::query_as("SELECT user_id FROM sessions WHERE token = $1")
            .bind(&token)
            .fetch_optional(pool)
            .await
            .ok()?;

    row.map(|r| r.0)
}

pub async fn register(
    pool: web::Data<PgPool>,
    body: web::Json<RegisterRequest>,
) -> HttpResponse {
    if body.username.len() < 3 {
        return HttpResponse::BadRequest().json(ApiResponse::<()>::err("Username must be at least 3 characters"));
    }

    let email_regex = regex::Regex::new(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").unwrap();
    if !email_regex.is_match(&body.email) {
        return HttpResponse::BadRequest().json(ApiResponse::<()>::err("Invalid email format"));
    }

    if body.password.len() < 8 {
        return HttpResponse::BadRequest().json(ApiResponse::<()>::err("Password must be at least 8 characters"));
    }

    let existing: Option<(Uuid,)> =
        sqlx::query_as("SELECT id FROM users WHERE email = $1")
            .bind(&body.email)
            .fetch_optional(pool.get_ref())
            .await
            .unwrap_or(None);

    if existing.is_some() {
        return HttpResponse::Conflict().json(ApiResponse::<()>::err("Email already registered"));
    }

    let password_hash = match bcrypt::hash(&body.password, 10) {
        Ok(h) => h,
        Err(_) => return HttpResponse::InternalServerError().json(ApiResponse::<()>::err("Failed to hash password")),
    };

    let user_id = Uuid::new_v4();

    let result = sqlx::query_as::<_, User>(
        "INSERT INTO users (id, username, email, password_hash) VALUES ($1, $2, $3, $4) RETURNING *"
    )
    .bind(user_id)
    .bind(&body.username)
    .bind(&body.email)
    .bind(&password_hash)
    .fetch_one(pool.get_ref())
    .await;

    match result {
        Ok(user) => {
            sqlx::query("INSERT INTO trust_scores (id, user_id, score, status) VALUES ($1, $2, 300, 'Healthy')")
                .bind(Uuid::new_v4())
                .bind(user_id)
                .execute(pool.get_ref())
                .await
                .ok();

            let token = generate_token();
            sqlx::query("INSERT INTO sessions (token, user_id) VALUES ($1, $2)")
                .bind(&token)
                .bind(user_id)
                .execute(pool.get_ref())
                .await
                .ok();

            HttpResponse::Ok().json(ApiResponse::ok(AuthResponse {
                user: user.into(),
                token,
            }))
        }
        Err(e) => HttpResponse::InternalServerError().json(ApiResponse::<()>::err(&format!("Registration failed: {}", e))),
    }
}

pub async fn login(
    pool: web::Data<PgPool>,
    body: web::Json<LoginRequest>,
) -> HttpResponse {
    let user = sqlx::query_as::<_, User>(
        "SELECT * FROM users WHERE email = $1"
    )
    .bind(&body.email)
    .fetch_optional(pool.get_ref())
    .await;

    match user {
        Ok(Some(user)) => {
            if !bcrypt::verify(&body.password, &user.password_hash).unwrap_or(false) {
                return HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Invalid email or password"));
            }

            let token = generate_token();
            sqlx::query("INSERT INTO sessions (token, user_id) VALUES ($1, $2)")
                .bind(&token)
                .bind(user.id)
                .execute(pool.get_ref())
                .await
                .ok();

            HttpResponse::Ok().json(ApiResponse::ok(AuthResponse {
                user: user.into(),
                token,
            }))
        }
        Ok(None) => HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Invalid email or password")),
        Err(e) => HttpResponse::InternalServerError().json(ApiResponse::<()>::err(&format!("Login failed: {}", e))),
    }
}

pub async fn me(
    pool: web::Data<PgPool>,
    req: HttpRequest,
) -> HttpResponse {
    let user_id = match get_user_from_token(pool.get_ref(), &req).await {
        Some(id) => id,
        None => return HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Not authenticated")),
    };

    let user = sqlx::query_as::<_, User>("SELECT * FROM users WHERE id = $1")
        .bind(user_id)
        .fetch_optional(pool.get_ref())
        .await;

    match user {
        Ok(Some(user)) => HttpResponse::Ok().json(ApiResponse::ok(UserResponse::from(user))),
        _ => HttpResponse::NotFound().json(ApiResponse::<()>::err("User not found")),
    }
}
