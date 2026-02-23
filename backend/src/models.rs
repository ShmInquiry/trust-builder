use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct User {
    pub id: Uuid,
    pub username: String,
    pub email: String,
    pub password_hash: String,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UserResponse {
    pub id: Uuid,
    pub username: String,
    pub email: String,
    pub created_at: DateTime<Utc>,
}

impl From<User> for UserResponse {
    fn from(u: User) -> Self {
        Self {
            id: u.id,
            username: u.username,
            email: u.email,
            created_at: u.created_at,
        }
    }
}

#[derive(Debug, Deserialize)]
pub struct RegisterRequest {
    pub username: String,
    pub email: String,
    pub password: String,
}

#[derive(Debug, Deserialize)]
pub struct LoginRequest {
    pub email: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct AuthResponse {
    pub user: UserResponse,
    pub token: String,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Request {
    pub id: Uuid,
    pub user_id: Uuid,
    pub title: String,
    pub description: String,
    pub status: String,
    pub stalled_days: i32,
    pub document_id: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct CreateRequestBody {
    pub title: String,
    pub description: String,
    pub status: Option<String>,
    pub peers: Option<Vec<String>>,
    pub document_id: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateRequestStatus {
    pub status: String,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct RequestPeer {
    pub id: Uuid,
    pub request_id: Uuid,
    pub peer_name: String,
}

#[derive(Debug, Serialize)]
pub struct RequestWithPeers {
    pub id: Uuid,
    pub user_id: Uuid,
    pub title: String,
    pub description: String,
    pub status: String,
    pub stalled_days: i32,
    pub document_id: Option<String>,
    pub peers: Vec<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct TrustScore {
    pub id: Uuid,
    pub user_id: Uuid,
    pub score: i32,
    pub status: String,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct NetworkPeer {
    pub id: Uuid,
    pub user_id: Uuid,
    pub peer_name: String,
    pub trust_level: String,
    pub interactions: i32,
    pub last_interaction: DateTime<Utc>,
    pub position_x: f64,
    pub position_y: f64,
}

#[derive(Debug, Serialize, Deserialize, FromRow)]
pub struct Alert {
    pub id: Uuid,
    pub user_id: Uuid,
    pub title: String,
    pub message: String,
    pub alert_type: String,
    pub is_read: bool,
    pub created_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct AlertFilter {
    pub filter: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct TrustScoreComputation {
    pub score: i32,
    pub status: String,
    pub factors: TrustFactors,
}

#[derive(Debug, Serialize)]
pub struct TrustFactors {
    pub completed_requests: i32,
    pub stalled_requests: i32,
    pub critical_requests: i32,
    pub total_interactions: i32,
    pub peer_count: i32,
}

#[derive(Debug, Serialize)]
pub struct ApiResponse<T: Serialize> {
    pub success: bool,
    pub data: Option<T>,
    pub error: Option<String>,
}

impl<T: Serialize> ApiResponse<T> {
    pub fn ok(data: T) -> Self {
        Self {
            success: true,
            data: Some(data),
            error: None,
        }
    }

    pub fn err(msg: &str) -> Self {
        Self {
            success: false,
            data: None,
            error: Some(msg.to_string()),
        }
    }
}
