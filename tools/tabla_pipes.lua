-- Pandoc filter for the slide decks: a `\|` inside an inline code span, on a
-- table row, becomes `|`. The deck sources follow GFM there, as the book does
-- (see tools/tabla_pipes.py); pandoc keeps such a row whole but would print
-- the backslash.
function Table(table)
  return table:walk({
    Code = function(code)
      code.text = code.text:gsub('\\|', '|')
      return code
    end,
  })
end
