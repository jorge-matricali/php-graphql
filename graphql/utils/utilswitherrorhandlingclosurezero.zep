namespace GraphQL\Utils;

class UtilswithErrorHandlingClosureZero
{
    private fn;
    private errors;

    public function __construct(fn, errors)
    {
                let this->fn = fn;
        let this->errors = errors;

    }

    public function __invoke()
    {
    // Catch custom errors (to report them in query results)
    set_error_handler(new UtilssuggestionListClosureOne(errors));
    try {
        return {this->fn}();
    } finally {
        restore_error_handler();
    }
    }
}
    