namespace GraphQL\Error;

class FormattedErrorprepareFormatterClosureOne
{

    public function __construct()
    {
        
    }

    public function __invoke(e)
    {
    return FormattedError::createFromException(e);
    }
}
    