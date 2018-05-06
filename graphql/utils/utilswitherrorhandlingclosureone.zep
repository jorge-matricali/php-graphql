namespace GraphQL\Utils;

class UtilswithErrorHandlingClosureOne
{
    private errors;

    public function __construct(errors)
    {
                let this->errors = errors;

    }

    public function __invoke(severity, message, file, line)
    {
    this->errors[];
    }
}
    