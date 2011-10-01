class SongGenerator
  @KEYS: ['A','Bb','B','C','C#','D','D#','E','F','F#','G','G#']

  constructor: (@rawData) ->
    @songdata = []
    @metadata = {}
    @_parseRawData()
    @_groupSections()

  _cleanLine: (line) ->
    line = line.trimRight()
    type = line.charAt 0
    data = line.substr(1)

    { type: type, data: data }

  _cleanBracket: (data) -> data.replace('[','').replace(']','')

  _parseRawData: () ->
    @lines = @rawData.split('\n')

    for line in @lines
      { type, data } = @_cleanLine line

      switch type
        # Metadata
        when '#'
          meta = data.split ':'
          @metadata[meta[0].toLowerCase()] = meta[1]
        # Section
        when '['
          data = @_cleanBracket data
          switch true
            when /^V/i.test(data) then @songdata.push type: 'section', data: data.replace(/^V/i,'Verse ')
            when /^C/i.test(data) then @songdata.push type: 'section', data: data.replace(/^C/i,'Chorus ')
            when /^P/i.test(data) then @songdata.push type: 'section', data: data.replace(/^P/i,'Pre-chorus ')
            when /^B/i.test(data) then @songdata.push type: 'section', data: data.replace(/^B/i,'Bridge ')
            when /^T/i.test(data) then @songdata.push type: 'section', data: data.replace(/^T/i,'Tag ')
            else @songdata.push type: 'section', data: data
        # Chord
        when '.' then @songdata.push type: 'chord',  data: data
        # Lyric
        when ' ' then @songdata.push type: 'lyric',  data: data
        # Comment
        when ';' then @songdata.push type: 'comment', data: data
        # Column Break
        when '-' then @songdata.push type: 'break',  data: data

  _groupSections: () ->
    @sections = []
    currentSection = []
    for item in @songdata
      if item.type is 'break'
         @columnBreakIndex = @sections.length
         continue
      if item.type is 'section'
        if currentSection?.length > 0
          @sections.push currentSection
        currentSection = []
      currentSection.push item
    if currentSection? then @sections.push currentSection
    @sections

  columnSplit: () ->
    columnA = []
    columnB = []
    if @columnBreakIndex
      for section, index in @sections
        if index <= @columnBreakIndex then columnA.push(section) else columnB.push(section)

    else
      median = Math.round(@lines.length / 2) + 5
      for section in @sections
        median -= section.length
        if median > 0 then columnA.push(section) else columnB.push(section)

    { columnA: columnA, columnB: columnB }

  # will take C# or Csharp since unescaped # won't work in a URL
  changeKey: (key) ->
    if !key then throw 'Must include a key to transpose to'
    if !@metadata.key then throw 'No #KEY provided for this song'

    keys = SongGenerator.KEYS
    keysLength = keys.length
    key = key.toUpperCase().replace('SHARP','#')
    if key is 'BB' then key = 'Bb'
    songKey = @metadata.key?.toUpperCase()
    if songKey is key then return

    transposeBy = keys.indexOf(key) - keys.indexOf(songKey)

    for line in @songdata
      if line.type is 'chord'
        line.data = line.data.replace /[A-G][b#]?/g, (match) ->
          index = keys.indexOf(match) + transposeBy
          if index < 0
            index = keysLength + index
          else if index >= keysLength
            index = index - keysLength
          keys[index]

    @metadata.key = key


module.exports = SongGenerator
