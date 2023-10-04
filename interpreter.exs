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

  def get_token(text, pos) do
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
  def expr(tokens) do
    %{values: values} = %{tokens: tokens, values: []} |> add_or_sub

    Enum.sum(values)
  end

  def add_or_sub(params) do
    [current_token | rest] = params.tokens

    case current_token.type do
      :add ->
        term(%{params | tokens: rest}) |> add_or_sub
      :sub ->
        result = term(%{params | tokens: rest})
        [head | tail] = result.values
        %{result | values: [-head | tail]} |> add_or_sub
      :int ->
        term(params) |> add_or_sub
      :eof ->
        params
      _ ->
        raise "Invalid token: #{current_token.type}"
    end
  end

  def term(params) do
    [current_token | rest] = params.tokens

    case current_token.type do
      :mul ->
        [left_val | tail] = params.values
        result = factor(%{params | tokens: rest})
        right_val = List.first(result.values)
        %{result | values: [left_val * right_val | tail]} |> term
      :div ->
        [left_val | tail] = params.values
        result = factor(%{params | tokens: rest})
        right_val = List.first(result.values)
        %{result | values: [left_val / right_val | tail]} |> term
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

  def factor(params) do
    [current_token | rest] = params.tokens

    if current_token.type == :int do
      %{tokens: rest, values: [current_token.value | params.values]}
    else
      raise "Invalid token: #{current_token.type}"
    end
  end
end

text = "-40-20*2+8/4+75+3"
tokens = Lexer.get_all_tokens(text)
result =  Interpreter.expr(tokens)
IO.inspect tokens
IO.inspect result
