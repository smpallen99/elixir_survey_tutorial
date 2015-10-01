# Elixir Voice Survey Tutorial <a id="top"></a>


A tutorial on using ExAdmin and SpeakEx to create a voice based survey application.

## Table of Contents
  * [The Elixir Side](#chapter-2)
    * [Web Application](#chapter-2.1)
      * [Create the Models](#chapter-2.1.3)
  * [Auto Administration](#chapter-2.2)
  * [Voice with Asterisk and SpeakEx](#chapter-3)
  * [Some Bells and Whistles](#chapter-4)
  * [License](#license)


## Getting Started

* Install the PhoenixFramework
* Install mysql 
* Install Asterisk
* Install swift_app on asterisk
* Setup Cepstral Text-to-speech on Asterisk

## The Elixir Side <a id="chapter-2"></a>

### Web Application with PhoenixFramework <a id="chapter-2.1"></a>

#### Create a new project <a id="chapter-2.1.1"></a>

- `mix phoenix.new elixir_survey_tutorial --database mysql --module Survey --app survey`

#### Setup the database <a id="chapter-2.1.2"></a>

* Edit `config/dev.conf` and set the `username` and `password`

```elixir
config :survey, Survey.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "steve",
  password: "elixirconf",
  ...
```

* Create the database
    `mix ecto.create`


#### Create the models <a id="chapter-2.1.3"></a>

We will use 5 models for this application.

* `Survey` to represent different surveys that will be configured
  - `name` to identify the survey (will be read to the caller)
  - `called_number` matches the dialed number to the appropriate survey

  `mix phoenix.gen.model Survey surveys name:string called_number:string`

* `Question` to represent a question in the survey
  - `name` the spoken question
  - `survey_id` the reference to its survey

  `mix phoenix.gen.model Question questions name:string survey_id:references:surveys`

* `Seating` to represent the results of someone taking the survey
  - `caller` the phone number of the caller
  - `survey_id` the reference to its survey

  `mix phoenix.gen.model Seating seatings caller:string survey_id:references:surveys`

* `Choice` to represent a choice for a question
  - `key` the digit pressed to select this choice
  - `name` the spoken text for this choice
  - `question_id` the reference to it's question

  `mix phoenix.gen.model Choice choices key:integer name:string question_id:references:questions`

* `Answer` to represent the choice selected during a survey
  - `seating_id` the reference to the seating
  - `question_id` the reference to the question
  - `choice_id` the reference to the choice

  `mix phoenix.gen.model Answer answers seating_id:references:seatings question_id:references:questions choice_id:references:choices`

Run the migrations with `mix ecto.migrate`

#### Setup the database associations <a id="chapter-2.1.4"></a>

A few more steps are needed to setup the has_many associations in the models 

web/models/survey.ex
```elixir
  schema "surveys" do
    field :name, :string
    field :called_number, :string
    has_many :questions, Survey.Question
    has_many :seatings, Survey.Seating

    timestamps
  end

  @required_fields ~w(name called_number)
```

web/models/question.ex
```elixir
  schema "questions" do
    field :name, :string
    belongs_to :survey, Survey.Survey
    has_many :choices, Survey.Choice
    has_many :answers, Survey.Answer

    timestamps
  end

  @required_fields ~w(name survey_id)
```

web/models/choice.ex
```elixir
  schema "choices" do
    field :key, :integer
    field :name, :string
    belongs_to :question, Survey.Question
    has_many :answers, Survey.Answer

    timestamps
  end

  @required_fields ~w(key name question_id)
```
web/models/seating.ex
```elixir
  schema "seatings" do
    field :caller, :string
    belongs_to :survey, Survey.Survey
    has_many :answers, Survey.Answer

    timestamps
  end

  @required_fields ~w(caller survey_id)
```

web/models/answer.ex
```elixir
  schema "answers" do
    belongs_to :seating, Survey.Seating
    belongs_to :question, Survey.Question
    belongs_to :choice, Survey.Choice

    timestamps
  end

  @required_fields ~w(seating_id question_id choice_id)
```

### Auto Administration with ExAdmin <a id="chapter-2.2"></a>

#### Add the ExAdmin dependency <a id="chapter-2.2.1"></a>

mix.exs
```elixir
  defp deps do
     ...
     {:ex_admin, github: "smpallen99/ex_admin"}, 
     ...
  end
```

* Get the dependency

```
mix do deps.get, compile
```

#### Configure ex_admin <a id="chapter-2.2.2"></a>

* install ex_admin

```
mix admin.install
``

* Add the admin routes

web/router.ex
```elixir
defmodule Survey.Router do
  use Survey.Web, :router
  use ExAdmin.Router
  ...
  # setup the ExAdmin routes
  admin_routes :admin

  scope "/", Survey do
  ...
```

* Add the paging configuration

lib/survey/repo.ex
```elixir
  defmodule Survey.Repo do
    use Ecto.Repo, otp_app: :survey
    use Scrivener, page_size: 10
  end

```

* Add some admin configuration and the admin modules to the config file

config/config.exs
```elixir
config :ex_admin, 
  repo: Survey.Repo,
  module: Survey,
  modules: [
    Survey.ExAdmin.Dashboard,
  ]
  ```

#### Give it a try

We now do a quick test to see the admin dashboard

```
iex -S mix phoenix.server
```

* Create the admin modules

```
mix admin.gen.resource Survey
mix admin.gen.resource Question
mix admin.gen.resource Choice
mix admin.gen.resource Seating
```

* Add the admin resources to the config file

config/config.ex
```elixir
config :ex_admin, 
  ...
  modules: [
    Survey.ExAdmin.Dashboard,
    Survey.ExAdmin.Survey,
    Survey.ExAdmin.Question,
    Survey.ExAdmin.Choice,
    Survey.ExAdmin.Seating,
  ]
```


#### Customize the Survey Resource
 
We would like to:

* Make it appear as 2nd menu item
* Show the questions configured
* We'll come back to the Survey resource and add reporting later

web/admin/survey.ex
```elixir
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
    end
  end
end
```

#### Customize the Question Resource

We would like to:

* Move the menu item to the 3rd position
* Show the associated Choices

web/admin/question.ex
```elixir
defmodule Survey.ExAdmin.Question do
  use ExAdmin.Register

  register_resource Survey.Question do
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
```

#### Customize the Seating Resource

We would like to:

* Disable the new button

web/admin/seating.ex
```elixir
defmodule Survey.ExAdmin.Seating do
  use ExAdmin.Register

  register_resource Survey.Seating do

    actions :all, except: [:new]

  end
end
```

## The Voice Side with Asterisk and SpeakEx <a id="chapter-3"></a>

#### Asterisk Configuration

We will now setup the voice communications with Asterisk

##### Add the AGI call to the extensions

/etc/asterisk/extensions_custom.conf
```
[from-internal-custom]
include => speak-ex

[speak-ex]
exten => _XXXX,1,Noop(SpeakEx Demo)
exten => _XXXX,n,AGI(agi://10.1.2.209:20000)
```

Ensure there is a AMI account in `/etc/asterisk/manager.conf`

Reload asterisk with `asterisk -rx reload`

## Complete the Application

#### Back to the project

* Add the dependencies

mix.exs
```elixir
      ...
      {:speak_ex, github: "smpallen99/speak_ex"},
      ...
```

* Add the configuration for :ex_ami, :speak_ex, :erlagi

config/dev.exs
```elixir
config :ex_ami, 
  servers: [
    {:asterisk, [
      {:connection, {ExAmi.TcpConnection, [
        {:host, "0.0.0.0"}, {:port, 5038}
      ]}},
      {:username, "elixirconf"},
      {:secret, "elixirconf"}
    ]} ]

config :erlagi,
  listen: [
    {:localhost, host: '0.0.0.0', port: 20000, backlog: 5, callback: SpeakEx.CallController}
  ]
```

* Add the swift renderer 

config/config.exs
```elixir
...
config :speak_ex, :renderer, :swift_app
```

* Add the voice applications to the application list

mix.exs
```elixir
  def application do
    [mod: {Survey, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger,
                    :phoenix_ecto, :mariaex, 
                    :ex_ami, :erlagi, :speak_ex]]
  end
```

* Get the new dependencies

```
mix do deps.get, compile
```

#### Create the call router

lib/survey/call_router.ex
```elixir
defmodule Survey.CallRouter do
  use SpeakEx.Router

  router do 
    route "Survey", Survey.SurveyController # , to: ~r/5555/
  end
end
```

#### Create a call controller

lib/survey/survey_controller.ex
```elixir
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
```

### Time to add a survey, some questions and choices to the database

* Create a Survey
* Create a couple Questions
* Create a few Options 

* Test the survey

## Some Bells and Whistles <a id="chapter-4"></a>

#### Add answers to the seating resource

We would like to:

* List the answers 
* Disable the new button

web/admin/seating.ex
```elixir
defmodule Survey.ExAdmin.Seating do
  use ExAdmin.Register

  register_resource Survey.Seating do

    actions :all, except: [:new]

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
```

#### Add reporting to the survey page

web/admin/survey.ex
```elixir
defmodule Survey.ExAdmin.Survey do
  use ExAdmin.Register

  register_resource Survey.Survey do

    menu priority: 2

    show survey do
      attributes_table

      panel "Questions" do
        table_for(survey.questions) do
          column :id
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
```

## License <a id="license"></a>

This tutorial is Copyright (c) 2015 E-MetroTel

The source code is released under the MIT License.

Check [LICENSE](LICENSE) for more information.
