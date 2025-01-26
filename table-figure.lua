-- This filter enables markdown text (@tbl:people) to be replaced by "Table N"
-- with a cross reference to the table's caption.  i.e.
--
--| First | Last     |
--|-------|----------|
--| Chad  | Skeeters |
--| John  | Doe      |
--
--Table:  People I know {#tbl:people}
--
-- See the people I know in @tbl:people.


local logging = require 'logging'

local table_no = 0
local table_nos = {} -- mark -> table_no

-- Adds mark to figures in Typst output
function typst_mark_table(elem, mark)
  if mark ~= nil then
    local m = pandoc.RawBlock('typst', '<tbl:'..mark..'>')
    return {elem, m}
  else
    return elem
  end
end

-- Returns the mark string for the table or nil for no mark
function get_mark(elem)
  local mark = nil

  function set_mark_str(elem)
    local s, e, m = string.find(elem.text, "{#tbl:([^%s]*)}")
    if s then
      -- only set the mark if we found the string
      mark = m
      return {}
    end
    return elem.content
  end

  function set_mark_plain(elem)
    while elem.content[#elem.content].t == "Space" do
      table.remove(elem.content)
    end
    return pandoc.Plain(elem.content)
  end


  -- Set the mark if there is one
  elem.caption.long = elem.caption.long:walk({
    Str = set_mark_str
  })

  -- Remove tailing space
  elem.caption.long = elem.caption.long:walk({
    Plain = set_mark_plain
  })

  return mark
end

-- This function determines the table number that will be assigned when the
-- caption is used under the figure.
function track_tables(elem)
  local mark = get_mark(elem)
  -- Save table numbers
  table_no = table_no + 1
  if mark ~= nil then
    table_nos[mark] = table_no
  end

  if FORMAT == 'typst' then
    return typst_mark_table(elem, mark)
  end
  if FORMAT == 'native' then
    return typst_mark_table(elem, mark)
  end
  return elem
end


function ref_table(elem)
  if string.sub(elem.text, 1, 1) ~= "+" then
    return elem
  end


  local s, e, mark, after = string.find(elem.text, "^+tbl:([a-zA-Z0-9_%-]*)(.*)")
  if s ~= nil then
    logging.info("  tbl: mark: "..mark)
    logging.info("  tbl: after: "..after)

    if FORMAT == 'typst' then
      return {pandoc.RawInline("typst", "@tbl:"..mark), pandoc.Str(after)}
    else
      return {pandoc.Str("Table "..table_nos[mark]), pandoc.Str(after)}
    end
  end

  return elem
end

function Pandoc(doc)
  -- First convert all table marks
  doc = doc:walk({
    Table = track_tables,
  })

  -- Now, update Table References
  return doc:walk({
    Str = ref_table,
  })
end
