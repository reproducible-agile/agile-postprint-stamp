# AGILE Postprint Stamp

[Shiny](https://shiny.rstudio.com/) application for adding a textbox to the first page of an AGILE short paper, so it can be uploaded to public preprint servers or institional repositories.

## ~~Use app online~~

_There currently is no online deployment of this app._

<a href="https://agile-postprint-stamp.herokuapp.com/"><img src="agile-postprint-stamp.png" title="Application screenshot" width="50%" /></a>

## Use app locally

1. Clone the repositoy
2. Generate the stamps for all years by running `R -f stamps.R`
3. Open `app.R` in RStudio
4. Click "Run App"

In R:

```r
git2r::clone("reproducible-agile/agile-postprint-stamp", local_path = ".")
renv::restore()
source("stamps.R")
shiny::runApp()
```

The project's dependencies are pinned in the [`renv.lock`](https://rstudio.github.io/renv/articles/lockfile.html) file.

## Use container locally

```bash
docker build --tag agile-postprint-stamp:local .
docker run -it --rm -p "8080:8080" agile-postprint-stamp:local
```

## Deploy app

### Heroku

- Add configuration as per https://github.com/virtualstaticvoid/heroku-docker-r (https://github.com/virtualstaticvoid/heroku-buildpack-r is not good with system deps)
  - `Aptfile`
  - `Dockerfile`
  - `heroku.yml`
  - `run.R`
- Create new app on Heroku (or use Heroku CLI) named `agile-postprint-stamp`
- Connect app to GitHub
- Activate the container stack with the Heroku CLI: `heroku stack:set container --app agile-postprint-stamp`
- Deploy `heroku` main branch, automatically

You should test the container locally before you deploy, see above.

### Shinyapps.io

Shinyapps currently does not have `qpdf`, and the package does not explose the required feature, see https://github.com/ropensci/qpdf/issues/11

```r
library("rsconnect")
rsconnect::deployApp(".", appFiles = c("app.R", "www", "stamp", "renv.lock"))
```

## Contribute

Please note that this project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

Please report bugs as GitHub issues.

_All contributions welcome!_

## License

Copyright 2020 Daniel Nüst. Project is published under GNU GPL v3 license, see file `LICENSE.md` for details.
