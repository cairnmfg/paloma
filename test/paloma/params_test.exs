defmodule Paloma.ParamsTest do
  alias Paloma.Params

  use Paloma.Test.DataCase

  describe "convert/2" do
    test "adds pagination arguments by default" do
      assert Params.convert(%{}) == [page: nil, page_size: nil]
    end

    test "permits pagination to be excluded" do
      result = Params.convert(%{}, paginate: false)
      assert result == []
    end

    test "assigns correct pagination values" do
      result = Params.convert(%{"size" => 1, "page" => 2})
      assert result == [page: 2, page_size: 1]
    end

    test "returns filters and sorts from whitelist" do
      filters = [bark_color: ["equal", "not_equal"], roots: ["equal", "not_equal"]]

      params = %{
        "bark_color" => %{"equal" => "Green"},
        "leaf_type" => %{"equal" => "broad"},
        "roots" => %{"bogus" => ["deep"]},
        "sort" => %{"asc" => "name", "bogus" => "height"}
      }

      sorts = ~w(name)
      result = Params.convert(params, filters: filters, sorts: sorts, paginate: false)
      assert result == [sort: {:asc, :name}, roots: [], bark_color: [equal: "Green"]]
    end

    test "supports list values for filters" do
      filters = [roots: ["equal", "not_equal"]]
      params = %{"roots" => %{"equal" => ["complex", "deep"]}}
      result = Params.convert(params, filters: filters, paginate: false)
      assert result == [roots: [equal: ["complex", "deep"]]]
    end
  end
end
