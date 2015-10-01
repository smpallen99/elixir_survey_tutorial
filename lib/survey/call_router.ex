defmodule Survey.CallRouter do
  use SpeakEx.Router

  router do 
    route "Survey", Survey.SurveyController # , to: ~r/5555/
  end
end
