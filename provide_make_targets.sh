#!/bin/sh
# Well, this is quick and and dirty. 
# And it's just a little helper script, it's not part of the package.
# I can't keep the R CMD stuff, and I'm used  to 'make', so I wrap R CMDs into
# make.

rpackage=$( basename $(pwd)) 
rpversion=$(grep 'Version:' DESCRIPTION |cut -f2 -d' ')

check_meta_info_script=tmp_check_meta_info.sh
cat > $check_meta_info_script <<EOF
## autogenerated by make.sh
find ./R -type f ! -name "*.swp" ! -name "*.tar.gz" -exec grep -i '~~' /dev/null {} \; 
find . -type f ! -name "*.swp" -exec grep -i 'kludge' /dev/null {} \; 
for target in Version Date 
do 
  v=\$( 
  grep --exclude=*.pdf --exclude=.*.swp -R "\${target}:" . | sed -e"s/.*\${target}: //" -e's/\\tab //'  \\
    | tr '\\\\' ' ' | cut -f1 -d' ' | uniq 
  ) 
  echo \$target \$v 
  [ \$(echo \$v | wc -w) -eq 1 ] || (printf "found different \${target}s \n"; exit 1) 
done
EOF
chmod 700 $check_meta_info_script


package_tools=tmp_package_tools.R
cat > $package_tools <<EOF
#!/usr/bin/Rscript --vanilla
package <- '$rpackage'
EOF
chmod 700 $package_tools
cat >> $package_tools <<\EOF
library(package, character.only = TRUE)

output_directory <- 'package_tools'
unlink(output_directory, recursive = TRUE)
dir.create(output_directory)



#% codetools
library('codetools')
# checkUsagePackage returns NULL, use sink
codetools_check <- capture.output(checkUsagePackage(package, all = TRUE))
outfile <- file.path(output_directory, "checkUsagePackage.out")
writeLines(codetools_check, outfile)
if(length(codetools_check) > 0) stop(paste("codetools failed, see ", outfile))

#% lintr
library('lintr')
linted <- lint_package(path = '.')
writeLines(unlist(lapply(linted, paste, collapse=" ")), 
           con = file.path(output_directory, "lint_package.out"))
#% formatR
library('formatR')
for (code_file in list.files(file.path('.', 'R'), full.names = TRUE)) {
    output_name <- file.path(output_directory, basename(code_file))
    file.copy(code_file, output_name)
    tidy_file <- paste(output_name, '.tidy', sep = '')
    tidy_source(code_file, arrow = TRUE, width.cutoff = 70, file = tidy_file)
    tidy_linted <- lint(tidy_file, linters = default_linters, cache = FALSE)
    if (length(tidy_linted) > 0)
        writeLines(unlist(lapply(tidy_linted, paste, collapse=" ")), 
                   con = paste(tidy_file, '.linted', sep = ''))
    code_linted <- lint(code_file, linters = default_linters, cache = FALSE)
    if (length(code_linted) > 0)
        writeLines(unlist(lapply(code_linted, paste, collapse=" ")), 
                   con = paste(output_name, '.linted', sep = ''))
}


EOF

cat > Makefile <<EOF
rpackage=${rpackage}
rpversion=${rpversion}
check_meta_info_script=$check_meta_info_script
package_tools=${package_tools}
EOF
cat >> Makefile <<\EOF
roxy_code=tmp_roxy.R

all: craninstall clean
full: crancheck install clean
craninstall: crancheck
	R --vanilla CMD INSTALL  ${rpackage}_${rpversion}.tar.gz
crancheck: check 
	export _R_CHECK_FORCE_SUGGESTS_=FALSE && \
        R CMD check --as-cran ${rpackage}_${rpversion}.tar.gz 
install: check 
	R --vanilla CMD INSTALL  ${rpackage}_${rpversion}.tar.gz && \
        printf '===== have you run\n\tmake check_demo && make package_tools\n?!\n' 
check: build 
	export _R_CHECK_FORCE_SUGGESTS_=FALSE && \
        R --vanilla CMD check ${rpackage}_${rpversion}.tar.gz && \
        printf '===== run\n\tmake install\n!!\n'
build: check_meta_info
	R --vanilla CMD build ../${rpackage}
check_meta_info: roxy
	./${check_meta_info_script}
direct_check:  
	R --vanilla CMD check ../${rpackage} ## check without build -- not recommended
roxy:
	rm man/* || true
	printf "library('roxygen2')\nroxygen2::roxygenize('.', roclets = c('rd'))\n" > ${roxy_code}
	R --vanilla CMD BATCH --vanilla ${roxy_code}
check_demo:
	# R CMD BATCH  demo/${rpackage}.R ## Rscript doesn't load
    # methods, but we fixed that.
	demo/${rpackage}.R

.PHONY: package_tools
package_tools:
	./${package_tools} # codetools needs to load the package, so we need make
    # install first
clean:
	rm Makefile 
	rm -rf ${rpackage}.Rcheck
remove:
	 R --vanilla CMD REMOVE  ${rpackage}
EOF