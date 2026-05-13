-- In Pandoc 3.x the field is 'colspec' (not 'col_spec').
-- Setting each ColWidth to nil signals ColWidthDefault, which makes Pandoc
-- emit w:tblLayout type="autofit" so the table stretches to full text width.
function Table(el)
  local specs = el.colspec
  if not specs then return el end
  local new = {}
  for _, spec in ipairs(specs) do
    new[#new + 1] = {spec[1], nil}
  end
  el.colspec = new
  return el
end
