namespace GraphQL\Validator\Rules;

use GraphQL\Error\Error;
use GraphQL\Validator\ValidationContext;
class CustomValidationRule extends AbstractValidationRule
{
    protected visitorFn;
    public function __construct(name, visitorFn) -> void
    {
        let this->name = name;
        let this->visitorFn = visitorFn;
    }
    
    /**
     * @param ValidationContext $context
     * @return Error[]
     */
    public function getVisitor(<ValidationContext> context) -> array
    {
        var fn;
    
        let fn =  this->visitorFn;
        return {fn}(context);
    }

}