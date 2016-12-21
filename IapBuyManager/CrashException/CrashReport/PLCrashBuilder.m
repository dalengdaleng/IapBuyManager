//
//  PLCrashBuilder.m
//  PRIS
//
//  Created by suns on 12-11-8.
//
//



#import "PLCrashBuilder.h"

@implementation PLCrashBuilder



#pragma mark - thread info



///**
// * @internal
// *
// * Write a thread message
// *
// * @param thread Thread for which we'll output data.
// * @param crashctx Context to use for currently running thread (rather than fetching the thread
// * context, which we've invalidated by running at all)
// */
//static size_t plcrash_writer_write_thread (thread_t thread, uint32_t thread_number, ucontext_t *crashctx) {
//    size_t rv = 0;
//    plframe_cursor_t cursor;
//    plframe_error_t ferr;
//    bool crashed_thread = false;
//    
//    NSMutableString *mstr = [NSMutableString string];
//    
//    /* Write the thread ID */
////    rv += plcrash_writer_pack(file, PLCRASH_PROTO_THREAD_THREAD_NUMBER_ID, PLPROTOBUF_C_TYPE_UINT32, &thread_number);
//    [mstr appendFormat:@"\nthreadnumber: %d", thread_number];
//    
//    /* Is this the crashed thread? */
//    thread_t thr_self = mach_thread_self();
//    if (MACH_PORT_INDEX(thread) == MACH_PORT_INDEX(thr_self))
//        crashed_thread = true;
//    
//    /* Set up the frame cursor. */
//    {
//        /* Use the crashctx if we're running on the crashed thread */
//        if (crashed_thread) {
//            ferr = plframe_cursor_init(&cursor, crashctx);
//            crashed_thread = true;
//        } else {
//            ferr = plframe_cursor_thread_init(&cursor, thread);
//        }
//        
//        /* Did cursor initialization succeed? */
//        if (ferr != PLFRAME_ESUCCESS) {
//            return 0;
//        }
//    }
//    
//    /* Walk the stack */
//    while ((ferr = plframe_cursor_next(&cursor)) == PLFRAME_ESUCCESS) {
////        uint32_t frame_size;
//        
//        /* Determine the size */
////        frame_size = plcrash_writer_write_thread_frame(NULL, &cursor);
//        
////        rv += plcrash_writer_pack(file, PLCRASH_PROTO_THREAD_FRAMES_ID, PLPROTOBUF_C_TYPE_MESSAGE, &frame_size);
////        rv += plcrash_writer_write_thread_frame(file, &cursor);
//    }
//    
//    /* Did we reach the end successfully? */
//    if (ferr != PLFRAME_ENOFRAME) {
//        
//    }
//    
//    /* Note crashed status */
////    rv += plcrash_writer_pack(file, PLCRASH_PROTO_THREAD_CRASHED_ID, PLPROTOBUF_C_TYPE_BOOL, &crashed_thread);
//    
//    /* Dump registers for the crashed thread */
//    if (crashed_thread) {
////        rv += plcrash_writer_write_thread_registers(file, crashctx);
//    }
//    
//    return rv;
//}
//
//static NSString *parseThreadsInfo()
//{
//    thread_act_array_t threads;
//    mach_msg_type_number_t thread_count;
//
//    task_t self = mach_task_self();
//    thread_t self_thr = mach_thread_self();
//
//    /* Get a list of all threads */
//    if (task_threads(self, &threads, &thread_count) != KERN_SUCCESS) {
//        thread_count = 0;
//    }
//
//    /* Suspend each thread and write out its state */
//    for (mach_msg_type_number_t i = 0; i < thread_count; i++) {
//        thread_t thread = threads[i];
//        uint32_t size;
//        bool suspend_thread = true;
//
//        /* Check if we're running on the to be examined thread */
//        if (MACH_PORT_INDEX(self_thr) == MACH_PORT_INDEX(threads[i])) {
//            suspend_thread = false;
//        }
//
//        /* Suspend the thread */
//        if (suspend_thread && thread_suspend(threads[i]) != KERN_SUCCESS) {
//            continue;
//        }
//
//
//        /* Write message */
////        plcrash_writer_write_thread(file, thread, i, crashctx);
//
//        /* Resume the thread */
//        if (suspend_thread)
//            thread_resume(threads[i]);
//    }
//
//    /* Clean up the thread array */
//    for (mach_msg_type_number_t i = 0; i < thread_count; i++)
//        mach_port_deallocate(mach_task_self(), threads[i]);
//    vm_deallocate(mach_task_self(), (vm_address_t)threads, sizeof(thread_t) * thread_count);
//    
//    
//    NSString *threadsInfo = nil;
//    
//    return threadsInfo;
//}


#pragma mark - signal info

/**
 * @ingroup plcrash_async_signal_info
 * @{
 */

struct signal_name {
    const int signal;
    const char *name;
};

struct signal_code {
    const int signal;
    const int si_code;
    const char *name;
};

#if __APPLE__
/* Values derived from <sys/signal.h> */
struct signal_name signal_names[] = {
    { SIGHUP,   "SIGHUP" },
    { SIGINT,   "SIGINT" },
    { SIGQUIT,  "SIGQUIT" },
    { SIGILL,   "SIGILL" },
    { SIGTRAP,  "SIGTRAP" },
    { SIGABRT,  "SIGABRT" },
#ifdef SIGPOLL
    // XXX Is this supported?
    { SIGPOLL,  "SIGPOLL" },
#endif
    { SIGIOT,   "SIGIOT" },
    { SIGEMT,   "SIGEMT" },
    { SIGFPE,   "SIGFPE" },
    { SIGKILL,  "SIGKILL" },
    { SIGBUS,   "SIGBUS" },
    { SIGSEGV,  "SIGSEGV" },
    { SIGSYS,   "SIGSYS" },
    { SIGPIPE,  "SIGPIPE" },
    { SIGALRM,  "SIGALRM" },
    { SIGTERM,  "SIGTERM" },
    { SIGURG,   "SIGURG" },
    { SIGSTOP,  "SIGSTOP" },
    { SIGTSTP,  "SIGTSTP" },
    { SIGCONT,  "SIGCONT" },
    { SIGCHLD,  "SIGCHLD" },
    { SIGTTIN,  "SIGTTIN" },
    { SIGTTOU,  "SIGTTOU" },
    { SIGIO,    "SIGIO" },
    { SIGXCPU,  "SIGXCPU" },
    { SIGXFSZ,  "SIGXFSZ" },
    { SIGVTALRM, "SIGVTALRM" },
    { SIGPROF,  "SIGPROF" },
    { SIGWINCH, "SIGWINCH" },
    { SIGINFO,  "SIGINFO" },
    { SIGUSR1,  "SIGUSR1" },
    { SIGUSR2,  "SIGUSR2" },
    { 0, NULL }
};

struct signal_code signal_codes[] = {
    /* SIGILL */
    { SIGILL,   ILL_NOOP,       "ILL_NOOP"    },
    { SIGILL,   ILL_ILLOPC,     "ILL_ILLOPC"  },
    { SIGILL,   ILL_ILLTRP,     "ILL_ILLTRP"  },
    { SIGILL,   ILL_PRVOPC,     "ILL_PRVOPC"  },
    { SIGILL,   ILL_ILLOPN,     "ILL_ILLOPN"  },
    { SIGILL,   ILL_ILLADR,     "ILL_ILLADR"  },
    { SIGILL,   ILL_PRVREG,     "ILL_PRVREG"  },
    { SIGILL,   ILL_COPROC,     "ILL_COPROC"  },
    { SIGILL,   ILL_BADSTK,     "ILL_BADSTK"  },
    
    /* SIGFPE */
    { SIGFPE,   FPE_NOOP,       "FPE_NOOP"    },
    { SIGFPE,   FPE_FLTDIV,     "FPE_FLTDIV"  },
    { SIGFPE,   FPE_FLTOVF,     "FPE_FLTOVF"  },
    { SIGFPE,   FPE_FLTUND,     "FPE_FLTUND"  },
    { SIGFPE,   FPE_FLTRES,     "FPE_FLTRES"  },
    { SIGFPE,   FPE_FLTINV,     "FPE_FLTINV"  },
    { SIGFPE,   FPE_FLTSUB,     "FPE_FLTSUB"  },
    { SIGFPE,   FPE_INTDIV,     "FPE_INTDIV"  },
    { SIGFPE,   FPE_INTOVF,     "FPE_INTOVF"  },
    
    /* SIGSEGV */
    { SIGSEGV,  SEGV_NOOP,      "SEGV_NOOP"   },
    { SIGSEGV,  SEGV_MAPERR,    "SEGV_MAPERR" },
    { SIGSEGV,  SEGV_ACCERR,    "SEGV_ACCERR" },
    
    /* SIGBUS */
    { SIGBUS,   BUS_NOOP,       "BUS_NOOP"    },
    { SIGBUS,   BUS_ADRALN,     "BUS_ADRALN"  },
    { SIGBUS,   BUS_ADRERR,     "BUS_ADRERR"  },
    { SIGBUS,   BUS_OBJERR,     "BUS_OBJERR"  },
    
    /* SIGTRAP */
    { SIGTRAP,  TRAP_BRKPT,     "TRAP_BRKPT"  },
    { SIGTRAP,  TRAP_TRACE,     "TRAP_TRACE"  },
    
    { 0, 0, NULL }
};
#else
#error Unsupported Platform
#endif


/**
 * @internal
 *
 * Map a signal code to a signal name, or return NULL if no
 * mapping is available.
 */
const char *plcrash_async_signal_sigcode (int signal, int si_code) {
    for (int i = 0; signal_codes[i].name != NULL; i++) {
        /* Check for match */
        if (signal_codes[i].signal == signal && signal_codes[i].si_code == si_code)
            return signal_codes[i].name;
    }
    
    /* No match */
    return NULL;
}

/**
 * @internal
 *
 * Map a normalized signal value to a SIGNAME signal string.
 */
const char *plcrash_async_signal_signame (int signal) {
    for (int i = 0; signal_names[i].name != NULL; i++) {
        /* Check for match */
        if (signal_names[i].signal == signal)
            return signal_names[i].name;
    }
    
    /* No match */
    return NULL;
}

/**
 * @internal
 * Signal handler context
 */
typedef struct signal_handler_ctx {
    
    /** Path to the output file */
    const char *path;
} plcrashreporter_handler_ctx_t;

NSString *parseSignalInfo(int signal, siginfo_t *siginfo)
{
    //  signal
    /* Fetch the signal name */
    char name_buf[10];
    const char *name;
    if ((name = plcrash_async_signal_signame(siginfo->si_signo)) == NULL) {
        snprintf(name_buf, sizeof(name_buf), "#%d", siginfo->si_signo);
        name = name_buf;
    }
    
    /* Fetch the signal code string */
    char code_buf[10];
    const char *code;
    if ((code = plcrash_async_signal_sigcode(siginfo->si_signo, siginfo->si_code)) == NULL) {
        snprintf(code_buf, sizeof(code_buf), "#%d", siginfo->si_code);
        code = code_buf;
    }
    
    NSString *signalString = [NSString stringWithFormat:@"fatal error: signalName:%s, signalCode:%s", name, code];
    
    return signalString;
}


@end
