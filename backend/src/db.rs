use sqlx::PgPool;

pub async fn create_tables(pool: &PgPool) -> Result<(), sqlx::Error> {
    let tables = vec![
        r#"CREATE TABLE IF NOT EXISTS users (
            id UUID PRIMARY KEY,
            username VARCHAR(100) NOT NULL UNIQUE,
            email VARCHAR(255) NOT NULL UNIQUE,
            password_hash VARCHAR(255) NOT NULL,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        )"#,
        r#"CREATE TABLE IF NOT EXISTS requests (
            id UUID PRIMARY KEY,
            user_id UUID NOT NULL REFERENCES users(id),
            title VARCHAR(255) NOT NULL,
            description TEXT NOT NULL DEFAULT '',
            status VARCHAR(20) NOT NULL DEFAULT 'fair',
            stalled_days INT NOT NULL DEFAULT 0,
            document_id VARCHAR(100),
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        )"#,
        r#"CREATE TABLE IF NOT EXISTS request_peers (
            id UUID PRIMARY KEY,
            request_id UUID NOT NULL REFERENCES requests(id) ON DELETE CASCADE,
            peer_name VARCHAR(100) NOT NULL
        )"#,
        r#"CREATE TABLE IF NOT EXISTS trust_scores (
            id UUID PRIMARY KEY,
            user_id UUID NOT NULL UNIQUE REFERENCES users(id),
            score INT NOT NULL DEFAULT 300,
            status VARCHAR(20) NOT NULL DEFAULT 'Healthy',
            updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        )"#,
        r#"CREATE TABLE IF NOT EXISTS network_peers (
            id UUID PRIMARY KEY,
            user_id UUID NOT NULL REFERENCES users(id),
            peer_name VARCHAR(100) NOT NULL,
            trust_level VARCHAR(20) NOT NULL DEFAULT 'Medium',
            interactions INT NOT NULL DEFAULT 0,
            last_interaction TIMESTAMPTZ NOT NULL DEFAULT NOW(),
            position_x DOUBLE PRECISION NOT NULL DEFAULT 0.0,
            position_y DOUBLE PRECISION NOT NULL DEFAULT 0.0
        )"#,
        r#"CREATE TABLE IF NOT EXISTS alerts (
            id UUID PRIMARY KEY,
            user_id UUID NOT NULL REFERENCES users(id),
            title VARCHAR(255) NOT NULL,
            message TEXT NOT NULL DEFAULT '',
            alert_type VARCHAR(20) NOT NULL DEFAULT 'system',
            is_read BOOLEAN NOT NULL DEFAULT FALSE,
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        )"#,
        r#"CREATE TABLE IF NOT EXISTS sessions (
            token VARCHAR(64) PRIMARY KEY,
            user_id UUID NOT NULL REFERENCES users(id),
            created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        )"#,
    ];

    for table_sql in tables {
        sqlx::query(table_sql).execute(pool).await?;
    }

    Ok(())
}

pub async fn seed_demo_data(pool: &PgPool) -> Result<(), sqlx::Error> {
    let user_count: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM users")
        .fetch_one(pool)
        .await?;

    if user_count.0 > 0 {
        return Ok(());
    }

    let demo_user_id = uuid::Uuid::new_v4();
    let password_hash = bcrypt::hash("demo1234", 10).unwrap();

    sqlx::query(
        "INSERT INTO users (id, username, email, password_hash) VALUES ($1, $2, $3, $4)"
    )
    .bind(demo_user_id)
    .bind("demo.user")
    .bind("demo@trustos.app")
    .bind(&password_hash)
    .execute(pool)
    .await?;

    sqlx::query(
        "INSERT INTO trust_scores (id, user_id, score, status) VALUES ($1, $2, $3, $4)"
    )
    .bind(uuid::Uuid::new_v4())
    .bind(demo_user_id)
    .bind(320)
    .bind("Healthy")
    .execute(pool)
    .await?;

    let req_ids: Vec<uuid::Uuid> = (0..5).map(|_| uuid::Uuid::new_v4()).collect();
    let requests = vec![
        (&req_ids[0], "Q3 Budget Alignment", "Align team spending with quarterly targets and submit final budget proposal.", "critical", 7, Some("DOC-4521")),
        (&req_ids[1], "Onboarding Checklist for New Hire", "Complete the onboarding checklist for the new team member starting next Monday.", "stalled", 3, None),
        (&req_ids[2], "Weekly Sync Feedback Loop", "Establish a recurring feedback loop during weekly syncs to track action items.", "fair", 0, None),
        (&req_ids[3], "Client Deliverable Review", "Review and approve the client deliverable before the Friday deadline.", "stalled", 4, Some("DOC-3387")),
        (&req_ids[4], "Team Trust Retrospective", "Schedule and facilitate a trust-building retrospective for the engineering team.", "fair", 0, None),
    ];

    for (id, title, desc, status, stalled, doc) in &requests {
        sqlx::query(
            "INSERT INTO requests (id, user_id, title, description, status, stalled_days, document_id) VALUES ($1, $2, $3, $4, $5, $6, $7)"
        )
        .bind(*id)
        .bind(demo_user_id)
        .bind(*title)
        .bind(*desc)
        .bind(*status)
        .bind(*stalled)
        .bind(*doc)
        .execute(pool)
        .await?;
    }

    let peers_data = vec![
        (&req_ids[0], vec!["Sarah Chen", "Marcus Lee"]),
        (&req_ids[1], vec!["Jordan Blake"]),
        (&req_ids[2], vec!["Priya Sharma", "Alex Kim", "Jordan Blake"]),
        (&req_ids[3], vec!["Sarah Chen"]),
        (&req_ids[4], vec!["Marcus Lee", "Priya Sharma"]),
    ];

    for (req_id, peers) in &peers_data {
        for peer in peers {
            sqlx::query(
                "INSERT INTO request_peers (id, request_id, peer_name) VALUES ($1, $2, $3)"
            )
            .bind(uuid::Uuid::new_v4())
            .bind(*req_id)
            .bind(*peer)
            .execute(pool)
            .await?;
        }
    }

    let network = vec![
        ("Sarah Chen", "High", 24, 0.3, 0.2),
        ("Marcus Lee", "High", 18, -0.2, -0.3),
        ("Priya Sharma", "Medium", 12, 0.4, -0.1),
        ("Jordan Blake", "Medium", 9, -0.3, 0.4),
        ("Alex Kim", "Low", 5, 0.1, 0.5),
        ("Taylor Morgan", "Low", 3, -0.4, 0.1),
    ];

    for (name, level, interactions, px, py) in &network {
        sqlx::query(
            "INSERT INTO network_peers (id, user_id, peer_name, trust_level, interactions, position_x, position_y) VALUES ($1, $2, $3, $4, $5, $6, $7)"
        )
        .bind(uuid::Uuid::new_v4())
        .bind(demo_user_id)
        .bind(*name)
        .bind(*level)
        .bind(*interactions)
        .bind(*px)
        .bind(*py)
        .execute(pool)
        .await?;
    }

    let alerts = vec![
        ("Budget Request Critical", "Q3 Budget Alignment has been stalled for 7 days and is now critical.", "request"),
        ("New Team Member Joining", "Jordan Blake's onboarding checklist needs attention before Monday.", "request"),
        ("Weekly Sync Scheduled", "Your weekly sync feedback loop is set for Thursday at 2pm.", "system"),
        ("Trust Score Updated", "Your Emotional Bank Account score has been recalculated: 320 (Healthy).", "system"),
        ("Deliverable Deadline Approaching", "Client Deliverable Review is due this Friday. Status: Stalled.", "request"),
    ];

    for (title, msg, atype) in &alerts {
        sqlx::query(
            "INSERT INTO alerts (id, user_id, title, message, alert_type) VALUES ($1, $2, $3, $4, $5)"
        )
        .bind(uuid::Uuid::new_v4())
        .bind(demo_user_id)
        .bind(*title)
        .bind(*msg)
        .bind(*atype)
        .execute(pool)
        .await?;
    }

    println!("Demo data seeded. Login: demo@trustos.app / demo1234");

    Ok(())
}
