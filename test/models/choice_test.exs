defmodule Survey.ChoiceTest do
  use Survey.ModelCase

  alias Survey.Choice

  @valid_attrs %{key: 42, name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Choice.changeset(%Choice{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Choice.changeset(%Choice{}, @invalid_attrs)
    refute changeset.valid?
  end
end
