output "db_connection_string_topasstoapp" {
    value = terraform_remote_state.remote-state.connection_strings
}