defmodule PalomaTest do
  alias Paloma.Test.{Beach, Cloud, Repo, Tree}

  use Paloma.Test.DataCase

  describe "create/1" do
    test "returns a changeset error tuple" do
      {:error, changeset} = Beach.create(%{})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "returns a resource tuple" do
      {:ok, resource} = Beach.create(%{name: "Mala"})
      assert resource.name == "Mala"
    end

    test "returns a bad request error tuple for the wrong type of arguments" do
      {:error, :bad_request} = Beach.create("bogus")
    end

    test "returns an UndefinedFunctionError error when resource does not include action" do
      assert_raise UndefinedFunctionError, fn ->
        Cloud.create(%{name: "Arcus"})
      end
    end
  end

  describe "delete/1 by ID" do
    test "returns a not found error tuple" do
      {:error, :not_found} = Beach.delete(123_456)
    end

    test "deletes a resource and returns a resource tuple" do
      {:ok, beach} = create(:beach)
      {:ok, _resource} = Beach.retrieve(beach.id)
      {:ok, resource} = Beach.delete(beach.id)
      assert resource.id == beach.id
      {:error, :not_found} = Beach.retrieve(beach.id)
    end

    test "returns a bad request error tuple for the wrong type of arguments" do
      {:error, :bad_request} = Beach.delete("bogus")
    end

    test "returns an UndefinedFunctionError error when resource does not include action" do
      {:ok, cloud} = create(:cloud)

      assert_raise UndefinedFunctionError, fn ->
        Cloud.delete(cloud.id)
      end
    end
  end

  describe "delete/1 by fields" do
    test "deletes a resource by name and returns a resource tuple" do
      {:ok, tree} = create(:tree, %{name: "Willow"})
      create(:tree)
      {:ok, _resource} = Tree.retrieve(tree.id)
      {:ok, resource} = Tree.delete(name: [equal: tree.name])
      assert resource.id == tree.id
      {:error, :not_found} = Tree.retrieve(tree.id)
    end
  end

  describe "list/1" do
    test "returns an empty list when no trees exist" do
      {:ok, page} = Tree.list()
      assert page.entries == []
      assert page.page_number == 1
      assert page.page_size == 20
      assert page.total_entries == 0
      assert page.total_pages == 1
    end

    test "returns existing trees" do
      {:ok, tree} = create(:tree)
      {:ok, %{entries: [result]} = page} = Tree.list()
      assert result == tree
      assert page.page_number == 1
      assert page.page_size == 20
      assert page.total_entries == 1
      assert page.total_pages == 1
    end

    test "paginates results" do
      create(:tree)
      {:ok, page} = Tree.list(page: 2, page_size: 10)
      assert page.entries == []
      assert page.page_number == 2
      assert page.page_size == 10
      assert page.total_entries == 1
      assert page.total_pages == 1
    end

    test "supports filtering results by name" do
      {:ok, tree} = create(:tree, %{name: "Cairn"})
      {:ok, page} = Tree.list(name: [equal: "Not Cairn"])
      assert page.entries == []
      {:ok, page} = Tree.list(name: [equal: ["Not Cairn"]])
      assert page.entries == []
      {:ok, page} = Tree.list(name: [not_equal: "Cairn"])
      assert page.entries == []
      {:ok, page} = Tree.list(name: [not_equal: ["Cairn"]])
      assert page.entries == []
      {:ok, %{entries: [result]}} = Tree.list(name: [equal: "Cairn"])
      assert result == tree
      {:ok, %{entries: [result]}} = Tree.list(name: [not_equal: "Not Cairn"])
      assert result == tree

      {:ok, %{entries: [result]}} = Tree.list(name: [equal: "Cairn", not_equal: "Not Cairn"])

      assert result == tree
    end

    test "returns an UndefinedFunctionError error when resource does not include action" do
      assert_raise UndefinedFunctionError, fn ->
        Cloud.list()
      end
    end
  end

  describe "retrieve/1 by ID" do
    test "returns a resource tuple by ID" do
      {:ok, beach} = create(:beach)
      {:ok, result} = Beach.retrieve(beach.id)
      assert beach == result
    end

    test "returns an UndefinedFunctionError error when resource does not include action" do
      {:ok, cloud} = create(:cloud)

      assert_raise UndefinedFunctionError, fn ->
        Cloud.retrieve(cloud.id)
      end
    end

    test "returns a not found error tuple" do
      {:error, :not_found} = Beach.retrieve(123_456)
    end
  end

  describe "retrieve/1 by fields" do
    test "returns a resource tuple when filters are defined" do
      create(:tree, %{name: "Birch", height: 11})
      create(:tree, %{name: "Willow", height: 11})
      {:ok, result} = Tree.retrieve(name: [equal: "Birch"], height: [equal: 11])
      assert result.name == "Birch"
      assert result.height == 11
    end

    test "returns a bad_request error tuple when filters are not defined" do
      create(:beach, %{name: "Birch"})
      {:error, :bad_request} = Beach.retrieve(name: [equal: "Birch"])
    end

    test "returns error for multiple matching results" do
      create(:tree, %{name: "Birch"})
      create(:tree, %{name: "Birch"})

      assert_raise Ecto.MultipleResultsError, fn ->
        Tree.retrieve(name: [equal: "Birch"])
      end
    end
  end

  defp create(type, data \\ %{})

  defp create(:beach, data) do
    %Beach{}
    |> Beach.changeset(Map.merge(%{name: "Mala", water: "salty"}, data))
    |> Repo.insert()
  end

  defp create(:cloud, data) do
    %Cloud{}
    |> Cloud.changeset(Map.merge(%{color: "Gray", name: "Wall"}, data))
    |> Repo.insert()
  end

  defp create(:tree, data) do
    %Tree{}
    |> Tree.changeset(Map.merge(%{bark_color: "brown", height: 15, name: "Birch"}, data))
    |> Repo.insert()
  end
end
