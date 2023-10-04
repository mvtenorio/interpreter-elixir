defmodule Token do
  defstruct [:type, :value, :next_pos]
end

defmodule Lexer do
  def get_all_tokens(text, pos \\ 0) do
    if pos <= String.length(text) do
      token = get_token(text, pos)
      [token | get_all_tokens(text, token.next_pos)]
    else
      []
    end
  end

  defp get_token(text, pos) do
    current_char = String.at(text, pos)

    case current_char do
      " " ->
        get_token(text, pos + 1)

      "+" ->
        %Token{type: :add, value: "+", next_pos: pos + 1}

      "-" ->
        %Token{type: :sub, value: "-", next_pos: pos + 1}

      "*" ->
        %Token{type: :mul, value: "*", next_pos: pos + 1}

      "/" ->
        %Token{type: :div, value: "/", next_pos: pos + 1}

      nil ->
        %Token{type: :eof}

      char ->
        case Integer.parse(char) do
          {digit, ""} ->
            case get_token(text, pos + 1) do
              %Token{type: :int, value: next_digit, next_pos: next_pos} ->
                %Token{
                  type: :int,
                  value: digit * 10 ** length(Integer.digits(next_digit)) + next_digit,
                  next_pos: next_pos
                }

              _ ->
                %Token{type: :int, value: digit, next_pos: pos + 1}
            end

          _ ->
            raise "Invalid character: #{char}"
        end
    end
  end
end

defmodule Interpreter do
  def eval(text) do
    tokens = Lexer.get_all_tokens(text)
    expr(%{tokens: tokens, total: 0}).total
  end

  defp expr(params) do
    [current_token | rest] = params.tokens

    case current_token.type do
      :add ->
        result = term(%{tokens: rest, total: params.total})
        %{result | total: params.total + result.total} |> expr

      :sub ->
        result = term(%{tokens: rest, total: params.total})
        %{result | total: params.total - result.total} |> expr

      :int ->
        term(params) |> expr

      :eof ->
        params

      _ ->
        raise "Invalid token: #{current_token.type}"
    end
  end

  defp term(params) do
    [current_token | rest] = params.tokens

    case current_token.type do
      :mul ->
        result = factor(%{params | tokens: rest})
        %{result | total: params.total * result.total} |> term

      :div ->
        result = factor(%{params | tokens: rest})
        %{result | total: params.total / result.total} |> term

      :int ->
        params |> factor |> term

      :add ->
        params

      :sub ->
        params

      :eof ->
        params

      _ ->
        raise "Invalid token: #{current_token.type}"
    end
  end

  defp factor(params) do
    [current_token | rest] = params.tokens

    if current_token.type == :int do
      %{tokens: rest, total: current_token.value}
    else
      raise "Invalid token: #{current_token.type}"
    end
  end
end

text = String.trim(IO.gets("calc> "))
result = Interpreter.eval(text)

IO.puts(result)
