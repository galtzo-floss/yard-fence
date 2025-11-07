# frozen_string_literal: true

# YARD plugin loader for `--plugin fence`.
# YARD tries requiring several patterns; providing `yard-fence` ensures
# it can be loaded regardless of whether YARD attempts `yard-fence` or `yard/fence`.
require_relative "yard/fence"
