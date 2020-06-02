defmodule Artemis.Repo.Migrations.CreateRecognitionsSearch do
  use Ecto.Migration

  def up do
    # 1. Create Search Data Column
    #
    # Define a column to store full text search data
    #
    alter table(:recognitions) do
      add :tsv_search, :tsvector
    end

    # 2. Create Search Data Index
    #
    # Create a GIN index on the full text search data column
    #
    create index(:recognitions, [:tsv_search], name: :recognitions_search_vector, using: "GIN")

    # 3. Define a Coalesce Function
    #
    # Coalesce the searchable fields into a single, space-separted, value. In
    # the example below the following user attributes are included in search:
    #
    # - email
    # - name
    # - first_name
    # - last_name
    #
    execute("""
      CREATE FUNCTION create_search_data_recognitions() RETURNS trigger AS $$
      begin
        new.tsv_search :=
          to_tsvector(
            'pg_catalog.english',
            coalesce(new.description, ' ')
          );
        return new;
      end
      $$ LANGUAGE plpgsql;
    """)

    # 4. Trigger the Function
    #
    # Call the function on `INSERT` and `UPDATE` actions
    #
    execute("""
      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON recognitions FOR EACH ROW EXECUTE PROCEDURE create_search_data_recognitions();
    """)
  end

  def down do
    # 1. Remove Triggers
    execute("drop function create_search_data_recognitions();")

    # 2. Remove Functions
    execute("drop trigger tsvectorupdate on recognitions;")

    # 3. Remove Indexes
    drop index(:recognitions, [:tsv_search])

    # 4. Remove Columns
    alter table(:recognitions) do
      remove :tsv_search
    end
  end
end
