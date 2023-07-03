google.charts.load('current', {
  'packages': ['corechart']
});
google.charts.setOnLoadCallback(requestCsv);

function requestCsv() {
  $.ajaxSetup({ cache: false });
  new CsvParser()
}

class Diagram {
  constructor(header) {
    this.header = header
    this.baseIndex = 1
    this.data = [
      ['Query ID']
    ];
    this.elem = document.getElementById('barcharts')
    this.commitHash = null
    this.queryIndex = null
    this.costOrRuntime = document.getElementById('cost-dropdown').value

    this.createDataObject()
  }

  createDataObject = () => {
    let indexCounter = 0
    for (let headerElem of this.header) {
      if (headerElem[0] == 'q') {
        if (this.queryIndex == null) {
          this.queryIndex = indexCounter
          console.log(`Index in CSV for first query ${this.queryIndex}`)
        }
        this.data.push([headerElem])
      }
      indexCounter++
    }
  }

  addUrl = () => {
    const url = 'https://github.com/hyrise/index_selection_evaluation/commit/' + this.commitHash
    let urlElement = document.createElement('a')
    let textNode = document.createTextNode(url)
    urlElement.appendChild(textNode)
    urlElement.href = url
    urlElement.target = '_blank'
    this.elem.appendChild(urlElement)
  }

  addTitle = () => {
    let headingElem = document.createElement('h2')
    let text = `Benchmarks with ${this.benchmark} and scale factor ${this.scaleFactor} `
    text += `(${this.dbSystem}, ${this.timestamp})`
    let titleElem = document.createTextNode(text)
    headingElem.appendChild(titleElem)
    this.elem.appendChild(headingElem);
  }

  draw = () => {
    if (this.data[0].length == 1) {
      console.log('not drawing')
      return
    }
    console.log(this.data)
    this.createTable()
    this.calculateRelativeValues()

    this.addTitle()
    this.addUrl()
    this.drawTable()

    let div = document.createElement('div')
    div.id = "chart_" + this.commitHash
    this.elem.appendChild(div)

    let chartData = google.visualization.arrayToDataTable(
      this.data
    )
    let subtitle = `benchmark: ${this.benchmark}, scale factor: ${this.scaleFactor}, database system: ${this.dbSystem}`
    let options = {
      title: 'Benchmark Results',
      width: this.data.length * 60 + 700,
      height: 800,
      chartArea: { left: 120 },
      legend: { position: 'top', maxLines: 2 },
      vAxis: {scaleType: 'log'},
      annotations: { style: 'line', textStyle: { fontSize: 9 } }
    };

    let chart = new google.visualization.ColumnChart(div);
    chart.draw(chartData, options);
  }

  storeMetaInfo = (line) => {
    this.timestamp = line[0]
    this.benchmark = line[5]
    this.scaleFactor = line[4]
    this.dbSystem = line[6]
    this.commitHash = line[1]
  }

  updateData = (line) => {
    this.storeMetaInfo(line)
    const algorithm = line[2]
    const parameters = line[3]
    const numberIndexes = line[8]

    for (let i = 1; i < this.data.length; i++) {
      let item = line[i + this.queryIndex - 1]
      let runtimes = JSON.parse(item)["Runtimes"]
      let cost = JSON.parse(item)["Cost"]
      if (runtimes.includes('null') && this.costOrRuntime == 'runtimes') {
        // TODO replace csv by json files?
        this.data[i].push(NaN)
        this.data[i].push('timeout')
      } else {
        // TODO remove if isArray later
        let float = runtimes
        if (this.costOrRuntime == 'costs') {
          float = cost
        }
        if (Array.isArray(float)) {
          float = float.reduce((a,b) => a + b, 0) / float.length
        }
        this.data[i].push(float)
        this.data[i].push(null)
      }
    }

    let legendString = `${algorithm}; parameters: ${parameters}, #indexes: ${numberIndexes}`
    this.data[0].push(legendString)
    this.data[0].push({ role: 'annotation' })
  }

  compareAlgorithm = (index, string) => {
    let result = [string]
    let valueSum = 0
    let baseValueSum = 0
    for (let i = 1; i < this.data.length; i++) {
      const value = this.data[i][index]
      const baseValue = this.data[i][this.baseIndex]
      if (!isNaN(value) && !isNaN(baseValue)) {
        result.push(value / baseValue)
        valueSum += value
        baseValueSum += baseValue
      } else {
        result.push(NaN)
      }
    }
    result.push('overall:')
    result.push(valueSum / baseValueSum)
    this.addRowToTable(result)
  }

  calculateRelativeValues = () => {
    for (let i = 3; i < this.data[0].length; i += 2) {
      const algorithmName = this.data[0][i].split(';')[0]
      const baseAlgorithm = this.data[0][this.baseIndex].split(';')[0]
      console.log(algorithmName)
      const string = `${algorithmName}/${baseAlgorithm}`

      this.compareAlgorithm(i, string)
    }
  }

  addRowToTable = (list) => {
    console.log(list)
    let row = document.createElement('tr')
    for (let elem of list) {
      let color = 'black'
      if (!isNaN(elem)) {
        elem = Math.round(elem * 100) / 100
        if (elem > 1.1) {
          color = 'red'
        } else if (elem < 0.9) {
          color = 'green'
        }
      }
      let cell = document.createElement('td')
      cell.style.color = color
      cell.appendChild(document.createTextNode(elem))
      row.appendChild(cell)
    }
    this.tableBody.appendChild(row)
  }

  createTable = () => {
    this.table = document.createElement('table')
    this.table.className = 'table'
    this.tableBody = document.createElement('tbody')
    let row = document.createElement('tr')
    for (let dataElem of this.data) {
      let cell = document.createElement('td')
      cell.appendChild(document.createTextNode(dataElem[0]))
      row.appendChild(cell)
    }
    this.tableBody.appendChild(row)
  }

  drawTable = () => {
    this.table.appendChild(this.tableBody)
    this.elem.appendChild(this.table);
    this.elem.appendChild(document.createElement('p'))
  }
}

class CsvParser {
  constructor() {
    this.csvData = null;
    this.header = null;
    this.dropdown = document.getElementById('benchmark-dropdown')
    this.elem = document.getElementById('barcharts')
    this.dropdown2 = document.getElementById('cost-dropdown')

    this.requestCsv();
    this.dropdown.onchange = () => {
      this.requestCsv()
    };
    this.dropdown2.onchange = () => {
      this.requestCsv()
    };
  }

  requestCsv() {
    let self = this
    let url = ''
    if (this.dropdown.value == 'tpch') {
      url = 'results_22_queries.csv'
    } else if (this.dropdown.value == 'tpcds') {
      url = 'results_99_queries.csv'
    } else if (this.dropdown.value == 'tpchsmall') {
      url = 'results_14_queries.csv'
    } else if (this.dropdown.value == 'tpcdssmall') {
      url = 'results_28_queries.csv'
    }
    $(document).ready(() => {
      $.ajax({
        type: "GET",
        url: url,
        dataType: "text",
        success: (data) => {
          self.csvData = data
          self.processCsvData()
        }
      });
    });
  }

  processCsvData() {
    this.elem.innerHTML = ''
    const lines = this.csvData.split('\n')
    this.header = lines[0].split(';')

    let currentCommit = 'None'
    let currentDiagram = new Diagram(this.header)

    for (let i = lines.length - 2; i > 0; i--) {
      const line = lines[i].split(';')
      const commitHash = line[1]
      if (currentCommit != commitHash) {
        currentDiagram.draw()
        currentCommit = commitHash
        currentDiagram = new Diagram(this.header)
      }
      currentDiagram.updateData(line)
    }
    currentDiagram.draw()
  }
}
