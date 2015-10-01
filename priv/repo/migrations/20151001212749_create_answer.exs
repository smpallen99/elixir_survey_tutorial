defmodule Survey.Repo.Migrations.CreateAnswer do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :seating_id, references(:seatings)
      add :question_id, references(:questions)
      add :choice_id, references(:choices)

      timestamps
    end
    create index(:answers, [:seating_id])
    create index(:answers, [:question_id])
    create index(:answers, [:choice_id])

  end
end
