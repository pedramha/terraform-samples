output "db_connection_string_topasstoapp" {
    value = data.terraform_remote_state.remote-state.outputs.connection_strings
}