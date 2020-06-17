# based on https://github.com/virtualstaticvoid/heroku-docker-r#shiny-applications
FROM virtualstaticvoid/heroku-docker-r:shiny

ENV PORT=8080

CMD ["/usr/bin/R", "--no-save", "--gui-none", "-f /app/run.R"]
