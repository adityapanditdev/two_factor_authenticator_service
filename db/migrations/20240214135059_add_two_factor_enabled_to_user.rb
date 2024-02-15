Sequel.migration do
  change do
    alter_table(:users) do
      add_column :two_factor_enabled, TrueClass, default: false
      add_column :token, String
    end
  end
end