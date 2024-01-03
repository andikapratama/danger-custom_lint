# Necessary for flutter analyze --write result that doesn't give rule info
# From https://dart-lang.github.io/linter/lints/options/options.html

FlutterViolation = Struct.new(:rule, :description, :file, :line, :column)

module Danger
  class DangerFlutterCustomLint < Plugin
    class CustomLintUnavailableError < StandardError
      def initialize(message = 'Cannot run custom lint, custom_lint dev_dependency not in pubspec')
        super(message)
      end
    end

    # Warning only, instead of fail
    # Default to false
    attr_accessor :warning_only

    # Report 0 issues found on success
    # Default to false
    attr_accessor :report_on_success

    # Pass modified_files (array of string) to allow only run custom_lint for modified packages
    def lint_packages(packages, &filter_block)
      @report_type = warning_only ? 'warn' : 'fail'

      violations = []
      packages.each do |package|
        report = lint_report(package.to_s)
        violations += parse_custom_lint_violations(report)
      end

      violations.each do |e|
        puts e
      end

      violations = violations.filter { |violation| filter_block.call(violation) } if filter_block

      send_markdown_comment(violations)
    end

    private

    # return flutter report
    def lint_report(package)
      puts "LINT REPORT |#{package}|"
      is_root = package.chomp.empty?
      unless is_root
        cd = `cd #{package}`
        puts "CD #{cd}"
      end
      result = `flutter pub get && flutter pub run custom_lint`
      puts result

      unless is_root
        cd = `cd ~-`
        puts "CD back #{cd}"
      end
      raise CustomLintUnavailableError if result.include?('Could not find package "custom_lint')

      result
    end

    # return Array<FlutterViolation>
    def parse_custom_lint_violations(report)
      return [] if report.empty? || report.include?('No issues found!')

      lines = report.split("\n")
      lines.map.with_index do |line, index|
        next unless line.match?(/ • /)

        info = line.split('•').map(&:strip)
        file_line = info[0]
        file, line_number, column = file_line.split(':')
        description = info[1]
        rule = info[2]
        puts "#{info.first} | #{info[1]}"
        FlutterViolation.new(rule, description, file, line_number.to_i, column.to_i)
      end.compact
    end

    def send_inline_comments(violations)
      violations.each do |violation|
        public_send(@report_type, violation.description, file: violation.file, line: violation.line)
      end
    end

    def send_markdown_comment(violations)
      if violations.empty?
        markdown '### Flutter Custom Lint found 0 issues ✅' if report_on_success
      else
        public_send(@report_type, markdown_table(violations))
      end
    end

    def markdown_table(violations)
      table = "### Flutter Custom Lint found #{violations.length} issues ❌\n\n"
      table << "| File | Line | Rule |\n"
      table << "| ---- | ---- | ---- |\n"

      violations.reduce(table) { |acc, violation| acc << table_row(violation) }
    end

    def table_row(violation)
      "| `#{violation.file}` | #{violation.line}:#{violation.column} | #{violation.rule} |\n"
    end
  end
end
