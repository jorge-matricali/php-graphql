namespace GraphQL\Validator;

class DocumentValidatorisErrorClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(item)
    {
    return item instanceof \Exception || item instanceof \Throwable;
    }
}
    