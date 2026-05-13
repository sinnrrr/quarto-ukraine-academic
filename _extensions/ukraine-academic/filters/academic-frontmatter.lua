local stringify = pandoc.utils.stringify

local function meta_string(value)
  if value == nil then return "" end
  return stringify(value)
end

local function meta_list(value)
  if value == nil then return {} end
  if type(value) == "table" then
    local result = {}
    for _, item in ipairs(value) do
      result[#result + 1] = stringify(item)
    end
    if #result > 0 then return result end
  end
  local text = stringify(value)
  if text == "" then return {} end
  return { text }
end

local function xml_escape(text)
  local escaped = text
  escaped = escaped:gsub("&", "&amp;")
  escaped = escaped:gsub("<", "&lt;")
  escaped = escaped:gsub(">", "&gt;")
  escaped = escaped:gsub('"', "&quot;")
  return escaped
end

local function is_quarto_metadata_para(block)
  if block.tag ~= "Para" then
    return false
  end
  if #block.content ~= 1 then
    return false
  end
  local el = block.content[1]
  return el.tag == "RawInline" and el.format == "html"
    and el.text:find("quarto%-file%-metadata", 1, true)
end

local function get_settings(meta)
  local settings = meta["ukraine-academic"]
  if type(settings) ~= "table" then
    return {}
  end
  return settings
end

local function lookup_setting(settings, key)
  local value = settings[key]
  if value ~= nil then return value end
  value = settings[key:gsub("%-", "_")]
  if value ~= nil then return value end
  value = settings[key:gsub("_", "-")]
  return value
end

local function get_config(meta)
  local s = get_settings(meta)
  return {
    institution_lines = meta_list(lookup_setting(s, "institution-lines")),
    faculty           = meta_string(lookup_setting(s, "faculty")),
    department        = meta_string(lookup_setting(s, "department")),
    work_type         = meta_string(lookup_setting(s, "work-type")),
    title_lines       = meta_list(lookup_setting(s, "title-lines")),
    student_label     = meta_string(lookup_setting(s, "student-label")),
    student_group     = meta_string(lookup_setting(s, "student-group")),
    author_short      = meta_string(lookup_setting(s, "author-short")),
    supervisor_role   = meta_string(lookup_setting(s, "supervisor-role")),
    supervisor_name   = meta_string(lookup_setting(s, "supervisor-name")),
    reviewer_role     = meta_string(lookup_setting(s, "reviewer-role")),
    reviewer_name     = meta_string(lookup_setting(s, "reviewer-name")),
    admitted_label    = meta_string(lookup_setting(s, "admitted-label")),
    department_head_label = meta_string(lookup_setting(s, "department-head-label")),
    department_head_role  = meta_string(lookup_setting(s, "department-head-role")),
    department_head_name  = meta_string(lookup_setting(s, "department-head-name")),
    signature_label   = meta_string(lookup_setting(s, "signature-label")),
    city              = meta_string(lookup_setting(s, "city")),
    year              = meta_string(lookup_setting(s, "year")),
  }
end

local TITLE_PAGE_XML = [=[
<w:p>
  <w:pPr>
    <w:jc w:val="center"/>
    <w:spacing w:before="72" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:b/>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>__INSTITUTION_LINE_1__</w:t>
  </w:r>
</w:p>
<w:p>
  <w:pPr>
    <w:jc w:val="center"/>
    <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:b/>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>__INSTITUTION_LINE_2__</w:t>
  </w:r>
</w:p>
<w:p>
  <w:pPr>
    <w:jc w:val="center"/>
    <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:b/>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>__INSTITUTION_LINE_3__</w:t>
  </w:r>
</w:p>
<w:p>
  <w:pPr>
    <w:spacing w:before="24" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
</w:p>
<w:p>
  <w:pPr>
    <w:jc w:val="center"/>
    <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>__FACULTY__</w:t>
  </w:r>
</w:p>
<w:p>
  <w:pPr>
    <w:jc w:val="center"/>
    <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>__DEPARTMENT__</w:t>
  </w:r>
</w:p>
<w:p>
  <w:pPr>
    <w:spacing w:before="1000" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
</w:p>
<w:p>
  <w:pPr>
    <w:jc w:val="center"/>
    <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:b/>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>__WORK_TYPE__</w:t>
  </w:r>
</w:p>
<w:p>
  <w:pPr>
    <w:spacing w:before="360" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
</w:p>
<w:p>
  <w:pPr>
    <w:jc w:val="center"/>
    <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:b/>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>Тема &#171;__TITLE_LINE_1__</w:t>
  </w:r>
</w:p>
<w:p>
  <w:pPr>
    <w:jc w:val="center"/>
    <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:b/>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>__TITLE_LINE_2__&#187;</w:t>
  </w:r>
</w:p>
<w:p>
  <w:pPr>
    <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
</w:p>
<w:tbl>
  <w:tblPr>
    <w:tblW w:w="9500" w:type="dxa"/>
    <w:jc w:val="center"/>
    <w:tblInd w:w="0" w:type="dxa"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="0" w:space="0" w:color="FFFFFF"/>
      <w:left w:val="single" w:sz="0" w:space="0" w:color="FFFFFF"/>
      <w:bottom w:val="single" w:sz="0" w:space="0" w:color="FFFFFF"/>
      <w:right w:val="single" w:sz="0" w:space="0" w:color="FFFFFF"/>
      <w:insideH w:val="single" w:sz="0" w:space="0" w:color="FFFFFF"/>
      <w:insideV w:val="single" w:sz="0" w:space="0" w:color="FFFFFF"/>
    </w:tblBorders>
    <w:tblLayout w:type="fixed"/>
    <w:tblLook w:val="0600" w:firstRow="0" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>
  </w:tblPr>
  <w:tblGrid>
    <w:gridCol w:w="7000"/>
    <w:gridCol w:w="2500"/>
  </w:tblGrid>
  <w:tr>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="7000" w:type="dxa"/>
        <w:tcMar>
          <w:top w:w="0" w:type="dxa"/>
          <w:left w:w="100" w:type="dxa"/>
          <w:bottom w:w="0" w:type="dxa"/>
          <w:right w:w="100" w:type="dxa"/>
        </w:tcMar>
      </w:tcPr>
      <w:p>
        <w:pPr>
          <w:jc w:val="left"/>
          <w:spacing w:before="900" w:after="0" w:line="360" w:lineRule="auto"/>
        </w:pPr>
        <w:r>
          <w:rPr>
            <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
            <w:sz w:val="28"/><w:szCs w:val="28"/>
          </w:rPr>
          <w:t>__STUDENT_LINE__</w:t>
        </w:r>
      </w:p>
    </w:tc>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="2500" w:type="dxa"/>
        <w:tcMar>
          <w:top w:w="0" w:type="dxa"/>
          <w:left w:w="100" w:type="dxa"/>
          <w:bottom w:w="0" w:type="dxa"/>
          <w:right w:w="100" w:type="dxa"/>
        </w:tcMar>
      </w:tcPr>
      <w:p>
        <w:pPr>
          <w:jc w:val="left"/>
          <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
        </w:pPr>
        <w:r>
          <w:rPr>
            <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
            <w:sz w:val="28"/><w:szCs w:val="28"/>
          </w:rPr>
          <w:t>__AUTHOR_SHORT__</w:t>
        </w:r>
      </w:p>
    </w:tc>
  </w:tr>
  <w:tr>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="7000" w:type="dxa"/>
        <w:tcMar>
          <w:top w:w="0" w:type="dxa"/>
          <w:left w:w="100" w:type="dxa"/>
          <w:bottom w:w="0" w:type="dxa"/>
          <w:right w:w="100" w:type="dxa"/>
        </w:tcMar>
      </w:tcPr>
      <w:p>
        <w:pPr>
          <w:jc w:val="left"/>
          <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
        </w:pPr>
        <w:r>
          <w:rPr>
            <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
            <w:sz w:val="28"/><w:szCs w:val="28"/>
          </w:rPr>
          <w:t>__SUPERVISOR_ROLE__</w:t>
        </w:r>
      </w:p>
    </w:tc>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="2500" w:type="dxa"/>
        <w:tcMar>
          <w:top w:w="0" w:type="dxa"/>
          <w:left w:w="100" w:type="dxa"/>
          <w:bottom w:w="0" w:type="dxa"/>
          <w:right w:w="100" w:type="dxa"/>
        </w:tcMar>
      </w:tcPr>
      <w:p>
        <w:pPr>
          <w:jc w:val="left"/>
          <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
        </w:pPr>
        <w:r>
          <w:rPr>
            <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
            <w:sz w:val="28"/><w:szCs w:val="28"/>
          </w:rPr>
          <w:t>__SUPERVISOR_NAME__</w:t>
        </w:r>
      </w:p>
    </w:tc>
  </w:tr>
  <w:tr>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="7000" w:type="dxa"/>
        <w:tcMar>
          <w:top w:w="0" w:type="dxa"/>
          <w:left w:w="100" w:type="dxa"/>
          <w:bottom w:w="0" w:type="dxa"/>
          <w:right w:w="100" w:type="dxa"/>
        </w:tcMar>
      </w:tcPr>
      <w:p>
        <w:pPr>
          <w:jc w:val="left"/>
          <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
        </w:pPr>
        <w:r>
          <w:rPr>
            <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
            <w:sz w:val="28"/><w:szCs w:val="28"/>
          </w:rPr>
          <w:t>__REVIEWER_ROLE__</w:t>
        </w:r>
      </w:p>
    </w:tc>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="2500" w:type="dxa"/>
        <w:tcMar>
          <w:top w:w="0" w:type="dxa"/>
          <w:left w:w="100" w:type="dxa"/>
          <w:bottom w:w="0" w:type="dxa"/>
          <w:right w:w="100" w:type="dxa"/>
        </w:tcMar>
      </w:tcPr>
      <w:p>
        <w:pPr>
          <w:jc w:val="left"/>
          <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
        </w:pPr>
        <w:r>
          <w:rPr>
            <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
            <w:sz w:val="28"/><w:szCs w:val="28"/>
          </w:rPr>
          <w:t>__REVIEWER_NAME__</w:t>
        </w:r>
      </w:p>
    </w:tc>
  </w:tr>
</w:tbl>
<w:p>
  <w:pPr>
    <w:spacing w:before="480" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
</w:p>
<w:p>
  <w:pPr>
    <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>__ADMITTED_LABEL__</w:t>
  </w:r>
</w:p>
<w:p>
  <w:pPr>
    <w:spacing w:before="240" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
      <w:t>__DEPARTMENT_HEAD_LABEL__</w:t>
  </w:r>
  <w:r>
    <w:t xml:space="preserve">      </w:t>
  </w:r>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>__________________</w:t>
  </w:r>
  <w:r>
    <w:t xml:space="preserve">      </w:t>
  </w:r>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>__DEPARTMENT_HEAD_LINE__</w:t>
  </w:r>
</w:p>
<w:p>
  <w:pPr>
    <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
    <w:ind w:left="2880"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="24"/><w:szCs w:val="24"/>
    </w:rPr>
      <w:t>__SIGNATURE_LABEL__</w:t>
  </w:r>
</w:p>
<w:p>
  <w:pPr>
    <w:spacing w:before="720" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
</w:p>
<w:p>
  <w:pPr>
    <w:jc w:val="center"/>
    <w:spacing w:before="0" w:after="0" w:line="360" w:lineRule="auto"/>
  </w:pPr>
  <w:r>
    <w:rPr>
      <w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:cs="Times New Roman"/>
      <w:sz w:val="28"/><w:szCs w:val="28"/>
    </w:rPr>
    <w:t>__CITY__, __YEAR__</w:t>
  </w:r>
</w:p>
]=]

local function build_openxml_frontmatter(cfg)
  local student_line = cfg.student_label
  if cfg.student_group ~= "" then
    student_line = student_line .. " " .. cfg.student_group
  end
  local title_line_1 = cfg.title_lines[1] or ""
  local title_line_2 = ""
  if #cfg.title_lines >= 2 then
    title_line_2 = table.concat({ table.unpack(cfg.title_lines, 2) }, " ")
  end
  local institution = cfg.institution_lines

  local replacements = {
    INSTITUTION_LINE_1 = xml_escape(institution[1] or ""),
    INSTITUTION_LINE_2 = xml_escape(institution[2] or ""),
    INSTITUTION_LINE_3 = xml_escape(institution[3] or ""),
    FACULTY = xml_escape(cfg.faculty),
    DEPARTMENT = xml_escape(cfg.department),
    WORK_TYPE = xml_escape(cfg.work_type),
    TITLE_LINE_1 = xml_escape(title_line_1),
    TITLE_LINE_2 = xml_escape(title_line_2),
    STUDENT_LINE = xml_escape(student_line),
    AUTHOR_SHORT = xml_escape(cfg.author_short),
    SUPERVISOR_ROLE = xml_escape(cfg.supervisor_role),
    SUPERVISOR_NAME = xml_escape(cfg.supervisor_name),
    REVIEWER_ROLE = xml_escape(cfg.reviewer_role),
    REVIEWER_NAME = xml_escape(cfg.reviewer_name),
    ADMITTED_LABEL = xml_escape(cfg.admitted_label),
    DEPARTMENT_HEAD_LABEL = xml_escape(cfg.department_head_label),
    DEPARTMENT_HEAD_LINE = xml_escape(cfg.department_head_role .. " " .. cfg.department_head_name),
    SIGNATURE_LABEL = xml_escape(cfg.signature_label),
    CITY = xml_escape(cfg.city),
    YEAR = xml_escape(cfg.year),
  }

  local content = TITLE_PAGE_XML
  for key, value in pairs(replacements) do
    content = content:gsub("__" .. key .. "__", value)
  end
  return content
end

function Pandoc(doc)
  if FORMAT ~= "docx" then
    return doc
  end

  local cfg = get_config(doc.meta)

  doc.meta.title = nil
  doc.meta.author = nil
  doc.meta.date = nil
  doc.meta.subtitle = nil

  while #doc.blocks > 0 and is_quarto_metadata_para(doc.blocks[1]) do
    table.remove(doc.blocks, 1)
  end
  while #doc.blocks > 0
    and doc.blocks[1].tag == "RawBlock"
    and doc.blocks[1].format == "html" do
    table.remove(doc.blocks, 1)
  end

  table.insert(doc.blocks, 1, pandoc.RawBlock("openxml", build_openxml_frontmatter(cfg)))
  return doc
end
