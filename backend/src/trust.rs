use actix_web::{web, HttpRequest, HttpResponse};
use sqlx::PgPool;

use crate::auth::get_user_from_token;
use crate::models::*;

pub fn compute_trust_score(
    completed: i32,
    stalled: i32,
    critical: i32,
    interactions: i32,
    peer_count: i32,
) -> TrustScoreComputation {
    let base = 300;
    let completed_bonus = completed * 20;
    let stalled_penalty = stalled * 15;
    let critical_penalty = critical * 30;
    let interaction_bonus = (interactions as f64 * 1.5) as i32;
    let peer_bonus = peer_count * 10;

    let score = (base + completed_bonus + interaction_bonus + peer_bonus
        - stalled_penalty - critical_penalty)
        .max(0)
        .min(1000);

    let status = if score >= 400 {
        "Healthy"
    } else if score >= 200 {
        "Fair"
    } else {
        "Critical"
    }
    .to_string();

    TrustScoreComputation {
        score,
        status,
        factors: TrustFactors {
            completed_requests: completed,
            stalled_requests: stalled,
            critical_requests: critical,
            total_interactions: interactions,
            peer_count,
        },
    }
}

pub async fn get_trust_score(
    pool: web::Data<PgPool>,
    req: HttpRequest,
) -> HttpResponse {
    let user_id = match get_user_from_token(pool.get_ref(), &req).await {
        Some(id) => id,
        None => return HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Not authenticated")),
    };

    let score = sqlx::query_as::<_, TrustScore>(
        "SELECT * FROM trust_scores WHERE user_id = $1"
    )
    .bind(user_id)
    .fetch_optional(pool.get_ref())
    .await;

    match score {
        Ok(Some(s)) => HttpResponse::Ok().json(ApiResponse::ok(s)),
        Ok(None) => HttpResponse::NotFound().json(ApiResponse::<()>::err("No trust score found")),
        Err(e) => HttpResponse::InternalServerError().json(ApiResponse::<()>::err(&format!("Error: {}", e))),
    }
}

pub async fn recalculate_trust_score(
    pool: web::Data<PgPool>,
    req: HttpRequest,
) -> HttpResponse {
    let user_id = match get_user_from_token(pool.get_ref(), &req).await {
        Some(id) => id,
        None => return HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Not authenticated")),
    };

    let completed: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM requests WHERE user_id = $1 AND status = 'completed'"
    )
    .bind(user_id)
    .fetch_one(pool.get_ref())
    .await
    .unwrap_or((0,));

    let stalled: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM requests WHERE user_id = $1 AND status = 'stalled'"
    )
    .bind(user_id)
    .fetch_one(pool.get_ref())
    .await
    .unwrap_or((0,));

    let critical: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM requests WHERE user_id = $1 AND status = 'critical'"
    )
    .bind(user_id)
    .fetch_one(pool.get_ref())
    .await
    .unwrap_or((0,));

    let interactions: (i64,) = sqlx::query_as(
        "SELECT COALESCE(SUM(interactions), 0) FROM network_peers WHERE user_id = $1"
    )
    .bind(user_id)
    .fetch_one(pool.get_ref())
    .await
    .unwrap_or((0,));

    let peers: (i64,) = sqlx::query_as(
        "SELECT COUNT(*) FROM network_peers WHERE user_id = $1"
    )
    .bind(user_id)
    .fetch_one(pool.get_ref())
    .await
    .unwrap_or((0,));

    let computation = compute_trust_score(
        completed.0 as i32,
        stalled.0 as i32,
        critical.0 as i32,
        interactions.0 as i32,
        peers.0 as i32,
    );

    sqlx::query(
        "UPDATE trust_scores SET score = $1, status = $2, updated_at = NOW() WHERE user_id = $3"
    )
    .bind(computation.score)
    .bind(&computation.status)
    .bind(user_id)
    .execute(pool.get_ref())
    .await
    .ok();

    HttpResponse::Ok().json(ApiResponse::ok(computation))
}

pub async fn list_network_peers(
    pool: web::Data<PgPool>,
    req: HttpRequest,
) -> HttpResponse {
    let user_id = match get_user_from_token(pool.get_ref(), &req).await {
        Some(id) => id,
        None => return HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Not authenticated")),
    };

    let peers = sqlx::query_as::<_, NetworkPeer>(
        "SELECT * FROM network_peers WHERE user_id = $1 ORDER BY interactions DESC"
    )
    .bind(user_id)
    .fetch_all(pool.get_ref())
    .await;

    match peers {
        Ok(p) => HttpResponse::Ok().json(ApiResponse::ok(p)),
        Err(e) => HttpResponse::InternalServerError().json(ApiResponse::<()>::err(&format!("Error: {}", e))),
    }
}
