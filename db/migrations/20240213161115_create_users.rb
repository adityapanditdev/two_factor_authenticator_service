Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :email, null: false
      String :password_digest, null: false
      # Add additional columns as needed
      # For example, you might include columns for two-factor authentication settings
      # such as enable_2fa, secret_key, etc.
      
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
