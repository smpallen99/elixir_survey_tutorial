defmodule Survey.Repo.Migrations.CreateSurvey do
  use Ecto.Migration

  def change do
    create table(:surveys) do
      add :name, :string
      add :called_number, :string

      timestamps
    end

  end
end
