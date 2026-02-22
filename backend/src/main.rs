mod models;
mod db;
mod auth;
mod requests;
mod trust;
mod alerts;

use actix_cors::Cors;
use actix_web::{web, App, HttpServer, HttpResponse, middleware};
use sqlx::postgres::PgPoolOptions;

async fn health() -> HttpResponse {
    HttpResponse::Ok().json(serde_json::json!({"status": "ok", "service": "trust-os-backend"}))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let database_url = std::env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set");

    println!("Connecting to database...");

    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&database_url)
        .await
        .expect("Failed to connect to database");

    println!("Connected to database. Creating tables...");

    db::create_tables(&pool)
        .await
        .expect("Failed to create tables");

    println!("Tables created. Seeding demo data...");

    db::seed_demo_data(&pool)
        .await
        .expect("Failed to seed demo data");

    println!("Starting Trust OS backend on http://0.0.0.0:3001");

    HttpServer::new(move || {
        let cors = Cors::permissive();

        App::new()
            .wrap(cors)
            .wrap(middleware::Logger::default())
            .app_data(web::Data::new(pool.clone()))
            .route("/health", web::get().to(health))
            .route("/api/auth/register", web::post().to(auth::register))
            .route("/api/auth/login", web::post().to(auth::login))
            .route("/api/auth/me", web::get().to(auth::me))
            .route("/api/requests", web::get().to(requests::list_requests))
            .route("/api/requests", web::post().to(requests::create_request))
            .route("/api/requests/{id}", web::get().to(requests::get_request))
            .route("/api/requests/{id}/status", web::put().to(requests::update_request_status))
            .route("/api/trust-score", web::get().to(trust::get_trust_score))
            .route("/api/trust-score/recalculate", web::post().to(trust::recalculate_trust_score))
            .route("/api/network", web::get().to(trust::list_network_peers))
            .route("/api/alerts", web::get().to(alerts::list_alerts))
            .route("/api/alerts/{id}/read", web::put().to(alerts::mark_alert_read))
    })
    .bind("0.0.0.0:3001")?
    .run()
    .await
}
