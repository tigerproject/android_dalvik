%default { "isrange":"0", "routine":"NoRange" }
%verify "executed"
%verify "unknown method"
    /*
     * Handle a direct method call.
     *
     * (We could defer the "is 'this' pointer null" test to the common
     * method invocation code, and use a flag to indicate that static
     * calls don't count.  If we do this as part of copying the arguments
     * out we could avoiding loading the first arg twice.)
     *
     */
     /* invoke-direct/jumbo {vCCCC..v(CCCC+BBBB-1)}, meth@AAAAAAAA */
    LOAD_rSELF_methodClassDex(a3)          #  a3 <- pDvmDex
    FETCH(a0, 1)                           # a0<- aaaa (lo)
    FETCH(a1, 2)                           # a1<- AAAA (hi)
    LOAD_base_offDvmDex_pResMethods(a3, a3) #  a3 <- pDvmDex->pResMethods
    sll     a1,a1,16
    or      a1, a0, a1                     # a1<- AAAAaaaa
    FETCH(rBIX, 4)                         #  rBIX <- GFED or CCCC
    LOAD_eas2(a0, a3, a1)                  #  a0 <- resolved methodToCall
    .if (!$isrange)
    and       rBIX, rBIX, 15               #  rBIX <- D (or stays CCCC)
    .endif
    EXPORT_PC()                            #  must export for invoke
    GET_VREG(rOBJ, rBIX)                   #  rOBJ <- "this" ptr
    # already resolved?
    bnez      a0, 1f                       #  resolved, call the function

    lw        a3, offThread_method(rSELF)  #  a3 <- self->method
    LOAD_base_offMethod_clazz(a0, a3)      #  a0 <- method->clazz
    li        a2, METHOD_DIRECT            #  resolver method type
    JAL(dvmResolveMethod)                  #  v0 <- call(clazz, ref, flags)
    move      a0, v0
    # got null?
    beqz      v0, common_exceptionThrown   #  yes, handle exception

1:
    bnez      rOBJ, common_invokeMethodJumbo #  a0=method, rOBJ="this"
    b         common_errNullObject         #  yes, throw exception



