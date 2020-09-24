'use strict'

let conns = require('./regularConnection')

let queries = {
    'get_project': 'select Id, Title, CreatedAt, Status from Project where Status=10 Limit 1',
    'get_parameters': 'select Id, ProjectId, Name, Value from ProjectParameters where ProjectId=?'
}

class Project {
    constructor(options) {
        this.options = options
        this.Parameters = []
    }

    load(callback) {
        conns.config.getConnection((err, conn) => {
            if (err && callback) callback(err)
            if (err) throw err
            conn.query(queries.get_project, (err, results) => {
                if (err && callback) callback(err)
                if (err) throw err

                this.setProjectProps(results[0])

                conn.query(queries.get_parameters, [this.Id], (err, results) => {
                    if (err && callback) callback(err)
                    if (err) throw err
                    this.setProjectParameters(results)
                    conn.destroy()
                    if (callback) callback(undefined)
                })
            })
        })
    }

    show() {
        console.log(`Id: ${this.Id} Title: ${this.Title} CratedAt: ${this.CreatedAt} Status: ${this.Status}`)
        this.Parameters.forEach(element => {
            console.log(`Name: ${element.Name} Value: ${element.Value} `)
        });
    }

    setProjectProps(row) {
        this.Id = row.Id
        this.Title = row.Title
        this.CreatedAt = row.CreatedAt
        this.Status = row.Status
    }

    setProjectParameters(rows) {
        rows.forEach(element => {
            this.Parameters.push(
                {
                    Id: element.Id,
                    Name: element.Name,
                    Value: element.Value
                }
            )
        });
    }

    getParameter(name) {
        if (!this.Parameters) throw 'project does not have any parameter'
        let match = this.Parameters.filter(ele => {
            return ele.Name == name
        })
        if (match.length > 0) {
            return match[0].Value
        }
        return undefined
    }

    existsParameter(name) {
        if (!this.Parameters) throw 'project does not have any parameter'
        return this.Parameters.find((ele) => ele.Name = name)
    }
}

module.exports = Project