defmodule Survey.SeatingTest do
  use Survey.ModelCase

  alias Survey.Seating

  @valid_attrs %{caller: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Seating.changeset(%Seating{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Seating.changeset(%Seating{}, @invalid_attrs)
    refute changeset.valid?
  end
end
