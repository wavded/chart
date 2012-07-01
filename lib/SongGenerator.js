var SongGenerator = function (rawData) {
   this.rawData = rawData
   this.songdata = []
   this.metadata = []
   this._parseRawData()
   this._groupSections()
}

SongGenerator.KEYS = ['A','Bb','B','C','C#','D','D#','E','F','F#','G','G#']

SongGenerator.prototype._cleanLine = function (line) {
   line = line.trimRight()
   return { type: line.charAt(0), data: line.substr(1) }
}

SongGenerator.prototype._cleanBracket = function (data) {
   return data.replace('[','').replace(']','')
}

SongGenerator.prototype._parseRawData = function () {
   this.lines = this.rawData.split('\n')

   var self = this
   this.lines.forEach(function (line) {
      line = self._cleanLine(line)

      switch (line.type) {
         // Metadata
         case '#':
            var meta = line.data.split(':')
            self.metadata[meta[0].toLowerCase()] = meta[1]
            break
         // Section
         case '[':
            var data = self._cleanBracket(line.data)
            if (/^V/i.test(data)) self.songdata.push({ type: 'section', data: data.replace(/^V/i,'Verse ') })
            else if (/^C/i.test(data)) self.songdata.push({ type: 'section', data: data.replace(/^C/i,'Chorus ') })
            else if (/^P/i.test(data)) self.songdata.push({ type: 'section', data: data.replace(/^P/i,'Pre-chorus ') })
            else if (/^B/i.test(data)) self.songdata.push({ type: 'section', data: data.replace(/^B/i,'Bridge ') })
            else if (/^T/i.test(data)) self.songdata.push({ type: 'section', data: data.replace(/^T/i,'Tag ') })
            else self.songdata.push({ type: 'section', data: data })
            break
         // Chord
         case '.':
            self.songdata.push({ type: 'chord',  data: line.data }); break
         // Lyric
         case ' ':
            self.songdata.push({ type: 'lyric',  data: line.data }); break
         // Comment
         case ';':
            self.songdata.push({ type: 'comment', data: line.data }); break
         // Column Break
         case '-':
            self.songdata.push({ type: 'break',  data: line.data });
      }
   })
}

SongGenerator.prototype._groupSections = function () {
   this.sections = []
   var currentSection = []

   var self = this
   this.songdata.forEach(function (item) {
      if (item.type === 'break') {
         self.columnBreakIndex = self.sections.length
         return
      }
      if (item.type === 'section') {
         if (currentSection && currentSection.length > 0)
            self.sections.push(currentSection)
         currentSection = []
      }
      currentSection.push(item)
   })
   if (currentSection) this.sections.push(currentSection)
   return this.sections
}

SongGenerator.prototype.columnSplit = function () {
   var columnA = []
   var columnB = []

   var self = this
   if (this.columnBreakIndex) {
      this.sections.forEach(function (section, index) {
         if (index <= self.columnBreakIndex)
            columnA.push(section)
         else columnB.push(section)
      })
   }
   else {
      var median = Math.round(this.lines.length / 2) + 5
      this.sections.forEach(function (section) {
         median -= section.length
         if (median > 0)
            columnA.push(section)
         else columnB.push(section)
      })
   }

   return { columnA: columnA, columnB: columnB }
}

// will take C# or Csharp since unescaped # won't work in a URL
SongGenerator.prototype.changeKey = function (key) {
   if (!key) throw 'Must include a key to transpose to'
   if (!this.metadata.key) throw 'No #KEY provided for this song'

   var keys = SongGenerator.KEYS
   var keysLength = keys.length
   var key = key.toUpperCase().replace('SHARP','#')
   if (key === 'BB') key = 'Bb'

   var songKey = (this.metadata.key || '').toUpperCase()
   if (songKey === key) return

   var transposeBy = keys.indexOf(key) - keys.indexOf(songKey)

   this.songdata.forEach(function (line) {
      if (line.type === 'chord') {
         line.data = line.data.replace(/[A-G][b#]?/g, function (match) {
            var index = keys.indexOf(match) + transposeBy
            if (index < 0)
               index = keysLength + index
            else if (index >= keysLength)
               index = index - keysLength
            return keys[index]
         })
      }
   })

   this.metadata.key = key
}

module.exports = SongGenerator
