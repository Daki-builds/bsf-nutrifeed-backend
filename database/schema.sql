-- BSF Nutrifeed Database Schema
-- SQL Dialect: PostgreSQL

-- Enum for User Roles
CREATE TYPE user_role AS ENUM ('farmer', 'admin');

-- 1. Users (Farmers, admins)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role user_role DEFAULT 'farmer',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enum for production status
CREATE TYPE batch_status AS ENUM ('planned', 'active', 'harvested', 'failed');

-- 2. Feed production records
CREATE TABLE feed_production_batches (
    id SERIAL PRIMARY KEY,
    farmer_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    batch_number VARCHAR(100) UNIQUE NOT NULL,
    start_date DATE NOT NULL,
    expected_harvest_date DATE,
    actual_harvest_date DATE,
    status batch_status DEFAULT 'planned',
    total_yield_kg DECIMAL(10, 2), -- the amount of feed produced at the end
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Monitoring data: Larvae growth logs
-- Used to track the health, environment, and development of a specific batch
CREATE TABLE larvae_growth_logs (
    id SERIAL PRIMARY KEY,
    batch_id INTEGER NOT NULL REFERENCES feed_production_batches(id) ON DELETE CASCADE,
    recorded_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    log_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    larvae_stage VARCHAR(50), -- e.g., 'egg', 'neonate', 'instar_1_to_5', 'prepupae', 'pupae'
    avg_weight_g DECIMAL(10, 4), -- average weight sample
    survival_rate_est DECIMAL(5, 2), -- estimated survival %
    temperature_c DECIMAL(5, 2), -- environmental temperature
    humidity_percent DECIMAL(5, 2), -- environmental humidity
    observations TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enum for log types
CREATE TYPE log_activity_type AS ENUM ('input', 'output');

-- 3. Monitoring data: Input/Output logs
-- Used to record what is fed into the system (organic waste, water) and what comes out (frass, harvested larvae)
CREATE TABLE input_output_logs (
    id SERIAL PRIMARY KEY,
    batch_id INTEGER NOT NULL REFERENCES feed_production_batches(id) ON DELETE CASCADE,
    recorded_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    log_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    activity_type log_activity_type NOT NULL,
    material_name VARCHAR(100) NOT NULL, -- e.g., 'Food Waste', 'Brewers Grain', 'Water', 'Frass (Fertilizer)'
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20) DEFAULT 'kg', -- 'kg', 'liters', 'grams'
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Optional: Indexes for performance on frequently queried columns
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_batches_farmer ON feed_production_batches(farmer_id);
CREATE INDEX idx_growth_logs_batch ON larvae_growth_logs(batch_id);
CREATE INDEX idx_io_logs_batch ON input_output_logs(batch_id);
