let Project = require('./../components/Project')
try {
    let project = new Project()

    project.load(() => project.show())

}
catch (ex) {
    throw ex
}