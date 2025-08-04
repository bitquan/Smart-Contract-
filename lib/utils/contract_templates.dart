import '../../models/contract_model.dart';

class ContractTemplates {
  static Map<String, dynamic> getServiceAgreementTemplate() {
    return {
      'title': 'Service Agreement',
      'fields': [
        {
          'key': 'providerName',
          'label': 'Service Provider Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'providerAddress',
          'label': 'Provider Address',
          'type': 'textarea',
          'required': true,
        },
        {
          'key': 'clientName',
          'label': 'Client Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'clientAddress',
          'label': 'Client Address',
          'type': 'textarea',
          'required': true,
        },
        {
          'key': 'serviceDescription',
          'label': 'Description of Services',
          'type': 'textarea',
          'required': true,
          'placeholder': 'Detailed description of services to be provided...',
        },
        {
          'key': 'serviceAmount',
          'label': 'Service Amount (\$)',
          'type': 'number',
          'required': true,
        },
        {
          'key': 'paymentTerms',
          'label': 'Payment Terms',
          'type': 'select',
          'options': [
            'Due upon completion',
            'Net 15 days',
            'Net 30 days',
            '50% upfront, 50% on completion',
            'Monthly payments',
            'Custom terms'
          ],
          'required': true,
        },
        {
          'key': 'startDate',
          'label': 'Service Start Date',
          'type': 'date',
          'required': true,
        },
        {
          'key': 'endDate',
          'label': 'Service End Date',
          'type': 'date',
          'required': false,
        },
        {
          'key': 'jurisdiction',
          'label': 'Governing Jurisdiction',
          'type': 'select',
          'options': [
            'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado',
            'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho',
            'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
            'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
            'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada',
            'New Hampshire', 'New Jersey', 'New Mexico', 'New York',
            'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon',
            'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota',
            'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
            'West Virginia', 'Wisconsin', 'Wyoming'
          ],
          'required': true,
        },
      ],
    };
  }

  static Map<String, dynamic> getNDATemplate() {
    return {
      'title': 'Non-Disclosure Agreement (NDA)',
      'fields': [
        {
          'key': 'disclosingParty',
          'label': 'Disclosing Party Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'receivingParty',
          'label': 'Receiving Party Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'purposeOfDisclosure',
          'label': 'Purpose of Information Disclosure',
          'type': 'textarea',
          'required': true,
          'placeholder': 'Describe the business purpose for sharing confidential information...',
        },
        {
          'key': 'ndaType',
          'label': 'NDA Type',
          'type': 'select',
          'options': [
            'Unilateral (One-way)',
            'Mutual (Two-way)',
          ],
          'required': true,
        },
        {
          'key': 'duration',
          'label': 'Duration of Agreement',
          'type': 'select',
          'options': [
            '1 year',
            '2 years',
            '3 years',
            '5 years',
            'Indefinite',
          ],
          'required': true,
        },
        {
          'key': 'jurisdiction',
          'label': 'Governing Jurisdiction',
          'type': 'select',
          'options': [
            'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado',
            'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho',
            'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
            'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
            'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada',
            'New Hampshire', 'New Jersey', 'New Mexico', 'New York',
            'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon',
            'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota',
            'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
            'West Virginia', 'Wisconsin', 'Wyoming'
          ],
          'required': true,
        },
      ],
    };
  }

  static Map<String, dynamic> getPaymentTermsTemplate() {
    return {
      'title': 'Payment Terms Agreement',
      'fields': [
        {
          'key': 'payerName',
          'label': 'Payer Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'payeeName',
          'label': 'Payee Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'totalAmount',
          'label': 'Total Amount (\$)',
          'type': 'number',
          'required': true,
        },
        {
          'key': 'paymentSchedule',
          'label': 'Payment Schedule',
          'type': 'select',
          'options': [
            'Lump sum payment',
            'Weekly payments',
            'Bi-weekly payments',
            'Monthly payments',
            'Milestone-based payments',
            'Custom schedule',
          ],
          'required': true,
        },
        {
          'key': 'dueDate',
          'label': 'First Payment Due Date',
          'type': 'date',
          'required': true,
        },
        {
          'key': 'lateFee',
          'label': 'Late Fee (\$ or %)',
          'type': 'text',
          'required': false,
          'placeholder': 'e.g., \$50 or 5% per month',
        },
        {
          'key': 'paymentMethod',
          'label': 'Accepted Payment Methods',
          'type': 'multiselect',
          'options': [
            'Cash',
            'Check',
            'Bank transfer',
            'Credit card',
            'PayPal',
            'Venmo',
            'Zelle',
          ],
          'required': true,
        },
        {
          'key': 'jurisdiction',
          'label': 'Governing Jurisdiction',
          'type': 'select',
          'options': [
            'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado',
            'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho',
            'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
            'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
            'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada',
            'New Hampshire', 'New Jersey', 'New Mexico', 'New York',
            'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon',
            'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota',
            'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
            'West Virginia', 'Wisconsin', 'Wyoming'
          ],
          'required': true,
        },
      ],
    };
  }

  static Map<String, dynamic> getContractorAgreementTemplate() {
    return {
      'title': 'Independent Contractor Agreement',
      'fields': [
        {
          'key': 'contractorName',
          'label': 'Contractor Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'companyName',
          'label': 'Company/Client Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'workDescription',
          'label': 'Description of Work',
          'type': 'textarea',
          'required': true,
          'placeholder': 'Detailed description of the work to be performed...',
        },
        {
          'key': 'compensationType',
          'label': 'Compensation Type',
          'type': 'select',
          'options': [
            'Fixed fee per project',
            'Hourly rate',
            'Daily rate',
            'Weekly rate',
            'Monthly retainer',
          ],
          'required': true,
        },
        {
          'key': 'compensationAmount',
          'label': 'Compensation Amount (\$)',
          'type': 'number',
          'required': true,
        },
        {
          'key': 'workLocation',
          'label': 'Work Location',
          'type': 'select',
          'options': [
            'Remote',
            'On-site at client location',
            'Contractor\'s location',
            'Hybrid (remote and on-site)',
          ],
          'required': true,
        },
        {
          'key': 'startDate',
          'label': 'Start Date',
          'type': 'date',
          'required': true,
        },
        {
          'key': 'endDate',
          'label': 'End Date (if applicable)',
          'type': 'date',
          'required': false,
        },
        {
          'key': 'intellectualProperty',
          'label': 'Intellectual Property Rights',
          'type': 'select',
          'options': [
            'All work belongs to client',
            'Contractor retains rights',
            'Shared ownership',
            'Custom arrangement',
          ],
          'required': true,
        },
        {
          'key': 'jurisdiction',
          'label': 'Governing Jurisdiction',
          'type': 'select',
          'options': [
            'Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado',
            'Connecticut', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho',
            'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana',
            'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota',
            'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada',
            'New Hampshire', 'New Jersey', 'New Mexico', 'New York',
            'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon',
            'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota',
            'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington',
            'West Virginia', 'Wisconsin', 'Wyoming'
          ],
          'required': true,
        },
      ],
    };
  }

  static Map<String, dynamic> getTemplateByType(ContractType type) {
    switch (type) {
      case ContractType.serviceAgreement:
        return getServiceAgreementTemplate();
      case ContractType.nda:
        return getNDATemplate();
      case ContractType.paymentTerms:
        return getPaymentTermsTemplate();
      case ContractType.contractorAgreement:
        return getContractorAgreementTemplate();
      case ContractType.photographyRelease:
        return getPhotographyReleaseTemplate();
      case ContractType.homeService:
        return getHomeServiceTemplate();
      case ContractType.freelanceAgreement:
        return getFreelanceAgreementTemplate();
      case ContractType.socialMediaContract:
        return getSocialMediaContractTemplate();
    }
  }

  // Placeholder templates for the remaining contract types
  static Map<String, dynamic> getPhotographyReleaseTemplate() {
    return {
      'title': 'Photography/Videography Release',
      'fields': [
        {
          'key': 'photographerName',
          'label': 'Photographer/Videographer Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'subjectName',
          'label': 'Subject Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'shootDate',
          'label': 'Date of Shoot',
          'type': 'date',
          'required': true,
        },
        {
          'key': 'usageRights',
          'label': 'Usage Rights',
          'type': 'multiselect',
          'options': [
            'Commercial use',
            'Editorial use',
            'Social media',
            'Print materials',
            'Website use',
            'Advertising',
          ],
          'required': true,
        },
        {
          'key': 'compensation',
          'label': 'Compensation (\$)',
          'type': 'number',
          'required': false,
        },
      ],
    };
  }

  static Map<String, dynamic> getHomeServiceTemplate() {
    return {
      'title': 'Home Service Agreement',
      'fields': [
        {
          'key': 'serviceProviderName',
          'label': 'Service Provider Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'homeownerName',
          'label': 'Homeowner Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'serviceType',
          'label': 'Type of Service',
          'type': 'select',
          'options': [
            'House cleaning',
            'Landscaping',
            'Home repair',
            'Tutoring',
            'Pet care',
            'Other',
          ],
          'required': true,
        },
        {
          'key': 'serviceDetails',
          'label': 'Service Details',
          'type': 'textarea',
          'required': true,
        },
        {
          'key': 'serviceAddress',
          'label': 'Service Address',
          'type': 'textarea',
          'required': true,
        },
        {
          'key': 'rate',
          'label': 'Rate (\$)',
          'type': 'number',
          'required': true,
        },
        {
          'key': 'schedule',
          'label': 'Service Schedule',
          'type': 'text',
          'required': true,
        },
      ],
    };
  }

  static Map<String, dynamic> getFreelanceAgreementTemplate() {
    return {
      'title': 'Freelance Work Agreement',
      'fields': [
        {
          'key': 'freelancerName',
          'label': 'Freelancer Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'clientName',
          'label': 'Client Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'projectType',
          'label': 'Project Type',
          'type': 'select',
          'options': [
            'Writing',
            'Graphic Design',
            'Web Development',
            'Marketing',
            'Consulting',
            'Other',
          ],
          'required': true,
        },
        {
          'key': 'projectDescription',
          'label': 'Project Description',
          'type': 'textarea',
          'required': true,
        },
        {
          'key': 'deliverables',
          'label': 'Deliverables',
          'type': 'textarea',
          'required': true,
        },
        {
          'key': 'deadline',
          'label': 'Project Deadline',
          'type': 'date',
          'required': true,
        },
        {
          'key': 'totalFee',
          'label': 'Total Project Fee (\$)',
          'type': 'number',
          'required': true,
        },
      ],
    };
  }

  static Map<String, dynamic> getSocialMediaContractTemplate() {
    return {
      'title': 'Social Media Management Contract',
      'fields': [
        {
          'key': 'managerName',
          'label': 'Social Media Manager Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'businessName',
          'label': 'Business/Client Name',
          'type': 'text',
          'required': true,
        },
        {
          'key': 'platforms',
          'label': 'Social Media Platforms',
          'type': 'multiselect',
          'options': [
            'Instagram',
            'Facebook',
            'Twitter',
            'LinkedIn',
            'TikTok',
            'YouTube',
            'Pinterest',
          ],
          'required': true,
        },
        {
          'key': 'services',
          'label': 'Services Included',
          'type': 'multiselect',
          'options': [
            'Content creation',
            'Post scheduling',
            'Community management',
            'Analytics reporting',
            'Paid advertising',
            'Strategy development',
          ],
          'required': true,
        },
        {
          'key': 'monthlyFee',
          'label': 'Monthly Fee (\$)',
          'type': 'number',
          'required': true,
        },
        {
          'key': 'contractDuration',
          'label': 'Contract Duration',
          'type': 'select',
          'options': [
            '1 month',
            '3 months',
            '6 months',
            '12 months',
            'Ongoing',
          ],
          'required': true,
        },
      ],
    };
  }
}