use actix_web::{web, HttpRequest, HttpResponse};
use sqlx::PgPool;
use uuid::Uuid;

use crate::auth::get_user_from_token;
use crate::models::*;

pub async fn list_alerts(
    pool: web::Data<PgPool>,
    req: HttpRequest,
    query: web::Query<AlertFilter>,
) -> HttpResponse {
    let user_id = match get_user_from_token(pool.get_ref(), &req).await {
        Some(id) => id,
        None => return HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Not authenticated")),
    };

    let alerts = match &query.filter {
        Some(f) if f != "all" => {
            sqlx::query_as::<_, Alert>(
                "SELECT * FROM alerts WHERE user_id = $1 AND alert_type = $2 ORDER BY created_at DESC"
            )
            .bind(user_id)
            .bind(f)
            .fetch_all(pool.get_ref())
            .await
        }
        _ => {
            sqlx::query_as::<_, Alert>(
                "SELECT * FROM alerts WHERE user_id = $1 ORDER BY created_at DESC"
            )
            .bind(user_id)
            .fetch_all(pool.get_ref())
            .await
        }
    };

    match alerts {
        Ok(a) => HttpResponse::Ok().json(ApiResponse::ok(a)),
        Err(e) => HttpResponse::InternalServerError().json(ApiResponse::<()>::err(&format!("Error: {}", e))),
    }
}

pub async fn mark_alert_read(
    pool: web::Data<PgPool>,
    req: HttpRequest,
    path: web::Path<Uuid>,
) -> HttpResponse {
    let user_id = match get_user_from_token(pool.get_ref(), &req).await {
        Some(id) => id,
        None => return HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Not authenticated")),
    };

    let alert_id = path.into_inner();

    let result = sqlx::query(
        "UPDATE alerts SET is_read = TRUE WHERE id = $1 AND user_id = $2"
    )
    .bind(alert_id)
    .bind(user_id)
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(r) if r.rows_affected() > 0 => {
            HttpResponse::Ok().json(ApiResponse::ok(serde_json::json!({"marked_read": true})))
        }
        Ok(_) => HttpResponse::NotFound().json(ApiResponse::<()>::err("Alert not found")),
        Err(e) => HttpResponse::InternalServerError().json(ApiResponse::<()>::err(&format!("Error: {}", e))),
    }
}
