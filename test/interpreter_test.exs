defmodule InterpreterTest do
  use ExUnit.Case
  doctest Interpreter

  test "addition" do
    assert Interpreter.eval("2+2") == 4
  end

  test "subtraction" do
    assert Interpreter.eval("4-3") == 1
  end

  test "multiplication" do
    assert Interpreter.eval("3*5") == 15
  end

  test "division" do
    assert Interpreter.eval("7/2") == 3.5
  end

  test "multiple operations" do
    assert Interpreter.eval("4*3+5-7/2") == 13.5
  end

  test "multiple digits" do
    assert Interpreter.eval("48-12*5+48/4") == 0.0
  end

  test "can start with minus (-)" do
    assert Interpreter.eval("-2+3") == 1
  end

  test "can start with plus (+)" do
    assert Interpreter.eval("+2+3") == 5
  end

  test "cannot start with multiplication sign (*)" do
    assert_raise RuntimeError, fn -> Interpreter.eval("*2+3") end
  end

  test "cannot start with division sign (/)" do
    assert_raise RuntimeError, fn -> Interpreter.eval("/2+3") end
  end

  test "invalid characters" do
    assert_raise RuntimeError, fn -> Interpreter.eval("2+&") end
  end

  test "allow whitespaces" do
    assert Interpreter.eval(" 12 + 3 ") == 15
  end

  @tag :skip
  test "allow dots" do
    assert Interpreter.eval("1.5+2.5") == 4.0
  end

  @tag :skip
  test "multiple minus signs" do
    assert Interpreter.eval("1--2") == 3
  end

  test "multiple plus signs" do
    assert Interpreter.eval("1++2") == 3
  end

  @tag :skip
  test "allow parenthesis" do
    assert Interpreter.eval("(2+3)*4") == 20
  end
end
