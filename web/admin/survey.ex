defmodule Survey.ExAdmin.Survey do
  use ExAdmin.Register

  register_resource Survey.Survey do
    menu priority: 2

    show survey do
      attributes_table

      panel "Questions" do
        table_for(survey.questions) do
          column :name
        end
      end
      panel "Results" do
        seating_count = Enum.count(survey.seatings)

        if  seating_count > 0 do
          markup_contents do
            table do
              thead do
                tr do
                  th "Question", colspan: 2
                  th "Responses"
                  th "Percent"
                end
              end
              tbody do
                Enum.reduce survey.questions, :even, fn(question, odd_even) ->
                  tr ".#{odd_even}" do
                    td question.name, colspan: 2
                    td "&nbsp;"
                    td "&nbsp;"
                  end
                  for choice <- question.choices do
                    cnt = Enum.count choice.answers
                    percent = Float.round(cnt / seating_count * 100, 2)
                    tr do
                      td ""
                      td choice.name
                      td format_entry("#{cnt}")
                      td format_entry("#{percent}%")
                    end
                  end
                  if odd_even == :even, do: :odd, else: :even
                end
              end
            end
          end
        end
      end
    end
    query do
      %{all: [preload: [{:questions, [choices: [:answers]]}, :seatings]]}
    end
  end

  defp format_entry(string) do
    String.rjust(string, 10) 
    |> String.replace(" ", "&nbsp;")
  end
end
