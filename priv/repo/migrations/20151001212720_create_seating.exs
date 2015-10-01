defmodule Survey.Repo.Migrations.CreateSeating do
  use Ecto.Migration

  def change do
    create table(:seatings) do
      add :caller, :string
      add :survey_id, references(:surveys)

      timestamps
    end
    create index(:seatings, [:survey_id])

  end
end
