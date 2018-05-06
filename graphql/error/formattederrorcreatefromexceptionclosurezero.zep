namespace GraphQL\Error;

class FormattedErrorcreateFromExceptionClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(SourceLocation loc)
    {
    return loc->toSerializableArray();
    }
}
    