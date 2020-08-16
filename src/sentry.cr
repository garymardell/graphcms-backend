require "sentry"

sentry = Sentry::ProcessRunner.new(
  display_name: "Kemal Dev",
  build_command: "crystal build ./src/app.cr -o ./bin/app",
  run_command: "./bin/app",
  files: ["./src/**/*.cr", "./src/**/*.ecr"]
)

sentry.run