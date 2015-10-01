defmodule Survey.ExAdmin.Question do
  use ExAdmin.Register

  register_resource Survey.Question do
    menu priority: 3

    show question do
      attributes_table
      panel "Choices" do
        table_for(question.choices) do
          column :key
          column :name
        end
      end
    end
  end
end
