defmodule Survey.ExAdmin.Seating do
  use ExAdmin.Register

  register_resource Survey.Seating do

    # actions :all, except: [:new]

    show seating do
      attributes_table
      panel "Answers" do
        table_for(seating.answers) do
          column "Question", fn(answer) -> 
            "#{answer.question.name}"
          end
          column "Answer", fn(answer) -> 
            "#{answer.choice.name}"
          end
        end
      end
    end

    query do
      %{all: [preload: [:survey, {:answers, [:choice, :question]}]]}
    end
  end
end
