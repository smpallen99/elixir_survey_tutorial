defmodule Survey.Repo do
  use Ecto.Repo, otp_app: :survey
  use Scrivener, page_size: 10
end
