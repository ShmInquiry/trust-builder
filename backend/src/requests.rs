use actix_web::{web, HttpRequest, HttpResponse};
use sqlx::PgPool;
use uuid::Uuid;

use crate::auth::get_user_from_token;
use crate::models::*;

pub async fn list_requests(
    pool: web::Data<PgPool>,
    req: HttpRequest,
) -> HttpResponse {
    let user_id = match get_user_from_token(pool.get_ref(), &req).await {
        Some(id) => id,
        None => return HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Not authenticated")),
    };

    let requests = sqlx::query_as::<_, Request>(
        "SELECT * FROM requests WHERE user_id = $1 ORDER BY
         CASE status WHEN 'critical' THEN 0 WHEN 'stalled' THEN 1 ELSE 2 END,
         stalled_days DESC"
    )
    .bind(user_id)
    .fetch_all(pool.get_ref())
    .await;

    match requests {
        Ok(reqs) => {
            let mut result = Vec::new();
            for r in reqs {
                let peers = sqlx::query_as::<_, RequestPeer>(
                    "SELECT * FROM request_peers WHERE request_id = $1"
                )
                .bind(r.id)
                .fetch_all(pool.get_ref())
                .await
                .unwrap_or_default();

                result.push(RequestWithPeers {
                    id: r.id,
                    user_id: r.user_id,
                    title: r.title,
                    description: r.description,
                    status: r.status,
                    stalled_days: r.stalled_days,
                    document_id: r.document_id,
                    peers: peers.into_iter().map(|p| p.peer_name).collect(),
                    created_at: r.created_at,
                    updated_at: r.updated_at,
                });
            }
            HttpResponse::Ok().json(ApiResponse::ok(result))
        }
        Err(e) => HttpResponse::InternalServerError().json(ApiResponse::<()>::err(&format!("Failed to fetch requests: {}", e))),
    }
}

pub async fn get_request(
    pool: web::Data<PgPool>,
    req: HttpRequest,
    path: web::Path<Uuid>,
) -> HttpResponse {
    let user_id = match get_user_from_token(pool.get_ref(), &req).await {
        Some(id) => id,
        None => return HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Not authenticated")),
    };

    let request_id = path.into_inner();

    let request = sqlx::query_as::<_, Request>(
        "SELECT * FROM requests WHERE id = $1 AND user_id = $2"
    )
    .bind(request_id)
    .bind(user_id)
    .fetch_optional(pool.get_ref())
    .await;

    match request {
        Ok(Some(r)) => {
            let peers = sqlx::query_as::<_, RequestPeer>(
                "SELECT * FROM request_peers WHERE request_id = $1"
            )
            .bind(r.id)
            .fetch_all(pool.get_ref())
            .await
            .unwrap_or_default();

            HttpResponse::Ok().json(ApiResponse::ok(RequestWithPeers {
                id: r.id,
                user_id: r.user_id,
                title: r.title,
                description: r.description,
                status: r.status,
                stalled_days: r.stalled_days,
                document_id: r.document_id,
                peers: peers.into_iter().map(|p| p.peer_name).collect(),
                created_at: r.created_at,
                updated_at: r.updated_at,
            }))
        }
        Ok(None) => HttpResponse::NotFound().json(ApiResponse::<()>::err("Request not found")),
        Err(e) => HttpResponse::InternalServerError().json(ApiResponse::<()>::err(&format!("Error: {}", e))),
    }
}

pub async fn create_request(
    pool: web::Data<PgPool>,
    req: HttpRequest,
    body: web::Json<CreateRequestBody>,
) -> HttpResponse {
    let user_id = match get_user_from_token(pool.get_ref(), &req).await {
        Some(id) => id,
        None => return HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Not authenticated")),
    };

    if body.title.trim().is_empty() {
        return HttpResponse::BadRequest().json(ApiResponse::<()>::err("Title is required"));
    }

    let request_id = Uuid::new_v4();

    let result = sqlx::query_as::<_, Request>(
        "INSERT INTO requests (id, user_id, title, description, document_id) VALUES ($1, $2, $3, $4, $5) RETURNING *"
    )
    .bind(request_id)
    .bind(user_id)
    .bind(body.title.trim())
    .bind(&body.description)
    .bind(&body.document_id)
    .fetch_one(pool.get_ref())
    .await;

    match result {
        Ok(r) => {
            let mut peer_names = Vec::new();
            if let Some(peers) = &body.peers {
                for peer in peers {
                    sqlx::query("INSERT INTO request_peers (id, request_id, peer_name) VALUES ($1, $2, $3)")
                        .bind(Uuid::new_v4())
                        .bind(request_id)
                        .bind(peer)
                        .execute(pool.get_ref())
                        .await
                        .ok();
                    peer_names.push(peer.clone());
                }
            }

            HttpResponse::Ok().json(ApiResponse::ok(RequestWithPeers {
                id: r.id,
                user_id: r.user_id,
                title: r.title,
                description: r.description,
                status: r.status,
                stalled_days: r.stalled_days,
                document_id: r.document_id,
                peers: peer_names,
                created_at: r.created_at,
                updated_at: r.updated_at,
            }))
        }
        Err(e) => HttpResponse::InternalServerError().json(ApiResponse::<()>::err(&format!("Failed to create: {}", e))),
    }
}

pub async fn update_request_status(
    pool: web::Data<PgPool>,
    req: HttpRequest,
    path: web::Path<Uuid>,
    body: web::Json<UpdateRequestStatus>,
) -> HttpResponse {
    let user_id = match get_user_from_token(pool.get_ref(), &req).await {
        Some(id) => id,
        None => return HttpResponse::Unauthorized().json(ApiResponse::<()>::err("Not authenticated")),
    };

    let request_id = path.into_inner();
    let valid_statuses = ["fair", "stalled", "critical", "completed"];

    if !valid_statuses.contains(&body.status.as_str()) {
        return HttpResponse::BadRequest().json(ApiResponse::<()>::err("Invalid status. Use: fair, stalled, critical, or completed"));
    }

    let result = sqlx::query(
        "UPDATE requests SET status = $1, updated_at = NOW() WHERE id = $2 AND user_id = $3"
    )
    .bind(&body.status)
    .bind(request_id)
    .bind(user_id)
    .execute(pool.get_ref())
    .await;

    match result {
        Ok(r) if r.rows_affected() > 0 => {
            HttpResponse::Ok().json(ApiResponse::ok(serde_json::json!({"updated": true})))
        }
        Ok(_) => HttpResponse::NotFound().json(ApiResponse::<()>::err("Request not found")),
        Err(e) => HttpResponse::InternalServerError().json(ApiResponse::<()>::err(&format!("Error: {}", e))),
    }
}
