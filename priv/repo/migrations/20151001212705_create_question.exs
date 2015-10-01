defmodule Survey.Repo.Migrations.CreateQuestion do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :name, :string
      add :survey_id, references(:surveys)

      timestamps
    end
    create index(:questions, [:survey_id])

  end
end
