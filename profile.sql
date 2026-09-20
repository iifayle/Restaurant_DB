create profile developer_profile limit
    password_life_time 180
    sessions_per_user 5
    failed_login_attempts 5
    password_lock_time 1
    password_reuse_time 10
    connect_time 480
    idle_time 60;
    
create profile admin_profile limit
    password_life_time 90
    sessions_per_user 3
    failed_login_attempts 3
    password_lock_time 1
    password_reuse_time 10
    connect_time 480
    idle_time 30;
    
create profile manager_profile limit
    password_life_time 90
    sessions_per_user 5
    failed_login_attempts 3
    password_lock_time 1
    password_reuse_time 10
    connect_time 480
    idle_time 30;
    
create profile client_profile limit
    password_life_time 180
    sessions_per_user 1
    failed_login_attempts 3
    password_lock_time 1
    password_reuse_time 10
    connect_time 60
    idle_time 15;