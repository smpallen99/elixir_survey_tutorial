defmodule Survey.SurveyController do
  require Logger
  use SpeakEx.CallController
  use SpeakEx.CallController.Menu
  import Ecto.Query

  def run(call) do
    call
    |> answer!
    |> run_survey
    |> hangup!
    |> terminate!
  end

  defp run_survey(call) do
    called_number = SpeakEx.Utils.get_channel_variable call, :to
    caller = SpeakEx.Utils.get_channel_variable call, :from
    survey = Survey.Survey
    |> where([q], q.called_number == ^called_number)
    |> preload(questions: [:choices])
    |> Survey.Repo.one!

    {:ok, seating} = Survey.Repo.insert %Survey.Seating{caller: caller, 
                       survey_id: survey.id}
    say call, "Welcome to the #{survey.name} survey"

    handle_questions(call, survey, seating)
  end

  defp handle_questions(call, survey, seating) do
    question_count = Enum.count survey.questions

    say call, [
      "This survey has #{question_count} questions",
      "Press the star key to repeat a question",
      "Lets start"
    ], interrupt: true

    Enum.reduce survey.questions, 1, fn(question, question_num) -> 
      handle_question(call, seating, question, question_num, question_count) 
    end

    call
    |> say!("That concludes the survey")
    |> say!("Thank you for participating")
  end

  defp build_menu_prompts(question, question_num, question_count) do
    count_prompt = "You have #{Enum.count question.choices} choice's"
    prefix = cond do 
      question_num == 1 -> "First Question"
      question_num == question_count -> "Last Question"
      true -> "Next Question"
    end
    prompts_reversed = [count_prompt, question.name, prefix]

    list = question.choices
    |> Enum.reduce(prompts_reversed, fn(choice, acc) -> 
        ["Press #{choice.key} for #{choice.name}" | acc]
    end) 

    Enum.reverse ["Please choose" | list]
  end


  defp handle_question(call, seating, question, question_num, question_count) do

    phrases = build_menu_prompts question, question_num, question_count

    valid_matches = Enum.reduce(question.choices, '', 
      &(Integer.to_char_list(&1.key) ++ &2))

    menu call, phrases, timeout: 8000, tries: 3 do
      match valid_matches, fn(press) -> 
        press = String.to_integer press
        choice = Enum.find question.choices, &(&1.key == press)
        case validate_question call, choice do
          :ok -> 
            %Survey.Answer{seating_id: seating.id, 
                           question_id: question.id, 
                           choice_id: choice.id} 
            |> Survey.Repo.insert
            :ok
          :repeat_question -> 
            :repeat
        end
      end
      match '*', fn -> 
        :repeat
      end
      invalid fn(press) -> 
        say! call, "#{press} is not a choice. Please try again"
        :invalid
      end 
      timeout fn -> 
        say call, "Please answer a little quicker"
      end
    end
    question_num + 1
  end

  defp validate_question(call, choice) do
    text = [
      "You have chosen ",
      choice.name,
      "Press 1 to confirm, or any other key to repeat the question"
    ]
    menu call, text, timeout: 5000, tries: 3 do
      match '1', fn -> :ok end
      default fn -> :repeat_question end
    end
  end
end
